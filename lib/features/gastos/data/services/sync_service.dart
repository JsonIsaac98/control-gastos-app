import 'package:logger/logger.dart';

import '../../../../features/categorias/data/datasources/categorias_local_datasource.dart';
import '../../../../features/categorias/data/datasources/categorias_remote_datasource.dart';
import '../../../../features/categorias/domain/entities/categoria_entity.dart';
import '../../../../features/presupuestos/data/datasources/presupuestos_local_datasource.dart';
import '../../../../features/presupuestos/data/datasources/presupuestos_remote_datasource.dart';
import '../../../../features/presupuestos/domain/entities/presupuesto_entity.dart';
import '../../../../features/tarjetas/data/datasources/tarjetas_local_datasource.dart';
import '../../../../features/tarjetas/data/datasources/tarjetas_remote_datasource.dart';
import '../../../../features/tarjetas/domain/entities/tarjeta_entity.dart';
import '../datasources/cuotas_local_datasource.dart';
import '../datasources/cuotas_remote_datasource.dart';
import '../datasources/gastos_local_datasource.dart';
import '../datasources/gastos_remote_datasource.dart';

// ----------------------------------------------------------------
// Resultado de una sincronización
// ----------------------------------------------------------------
class SyncResult {
  const SyncResult({
    required this.total,
    required this.synced,
    required this.failed,
    this.pulled = 0,
    this.deleted = 0,
  });

  /// Total de registros locales que estaban pendientes de subir.
  final int total;

  /// Registros subidos exitosamente a Supabase.
  final int synced;

  /// Registros que fallaron (en cualquier fase).
  final int failed;

  /// Registros descargados de Supabase e insertados localmente.
  final int pulled;

  /// Registros eliminados de Supabase y borrados físicamente de SQLite.
  final int deleted;

  bool get hasErrors => failed > 0;
  bool get allSynced => total > 0 && failed == 0;

  /// No había nada que hacer en ninguna dirección.
  bool get nothingToDo => total == 0 && pulled == 0 && deleted == 0;

  @override
  String toString() => 'SyncResult(total: $total, synced: $synced, '
      'failed: $failed, pulled: $pulled, deleted: $deleted)';
}

// ----------------------------------------------------------------
// SyncService — Puente SQLite → Supabase
// ----------------------------------------------------------------
/// Sincroniza los gastos locales pendientes (is_synced == false) con
/// la tabla `gastos` en Supabase, uno por uno, de forma resiliente.
///
/// Si un registro falla, continúa con el siguiente para no bloquear
/// el batch completo por un error puntual.
class SyncService {
  const SyncService({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.logger,
    required this.categoriasLocal,
    required this.categoriasRemote,
    required this.presupuestosLocal,
    required this.presupuestosRemote,
    required this.tarjetasLocal,
    required this.tarjetasRemote,
    required this.cuotasLocal,
    required this.cuotasRemote,
  });

  final GastosLocalDatasource localDatasource;
  final GastosRemoteDatasource remoteDatasource;
  final Logger logger;
  final CategoriasLocalDatasource categoriasLocal;
  final CategoriasRemoteDatasource categoriasRemote;
  final PresupuestosLocalDatasource presupuestosLocal;
  final PresupuestosRemoteDatasource presupuestosRemote;
  final TarjetasLocalDatasource tarjetasLocal;
  final TarjetasRemoteDatasource tarjetasRemote;
  final CuotasLocalDatasource cuotasLocal;
  final CuotasRemoteDatasource cuotasRemote;

  /// Ejecuta el ciclo completo de sincronización para [userId].
  ///
  /// Flujo por cada registro pendiente:
  ///   1. Consulta SQLite → gastos donde is_synced == false
  ///   2. Upsert en Supabase adjuntando el userId
  ///   3. Si Supabase responde 20X → marca is_synced = true en SQLite
  ///      y guarda el supabaseId para futuros updates
  Future<SyncResult> syncPendingGastos(String userId) async {
    int synced = 0;
    int failed = 0;

    // ── Paso 1: obtener todos los gastos no sincronizados ─────────
    final pending = await localDatasource.getUnsyncedGastos();

    if (pending.isEmpty) {
      logger.d('SyncService: No hay gastos pendientes de sincronizar.');
      return const SyncResult(total: 0, synced: 0, failed: 0);
    }

    logger.i('SyncService: Iniciando sync de ${pending.length} gasto(s)...');

    // ── Paso 2 & 3: enviar a Supabase y marcar en SQLite ──────────
    for (final gasto in pending) {
      try {
        // Enviar a Supabase con el UID del usuario autenticado
        final supabaseId = await remoteDatasource.upsertGasto(gasto, userId);

        // Supabase respondió 20X → marcar como sincronizado en SQLite
        await localDatasource.markAsSynced(gasto.id!, supabaseId);

        // Propagate supabaseId to related cuotas so they can sync next
        if (gasto.esCuota) {
          await cuotasLocal.updateGastoOrigenSupabaseId(gasto.id!, supabaseId);
        }

        synced++;
        logger.d(
          'SyncService: ✅ Gasto local #${gasto.id} '
          '→ Supabase $supabaseId',
        );
      } catch (e, stack) {
        // Error puntual: continúa con el siguiente registro
        failed++;
        logger.e(
          'SyncService: ❌ Error al sincronizar gasto #${gasto.id}',
          error: e,
          stackTrace: stack,
        );
      }
    }

    final result = SyncResult(
      total: pending.length,
      synced: synced,
      failed: failed,
    );

    logger.i('SyncService: Completado → $result');
    return result;
  }

  // ----------------------------------------------------------------
  // Sincronización bidireccional completa
  // ----------------------------------------------------------------
  /// Ejecuta las fases de sincronización en orden:
  ///  -1. **Categorías** — pull de categorías del sistema + usuario.
  ///   0. **Delete** — elimina de Supabase los gastos con [pendingDelete]=true.
  ///   1. **Push**   — sube gastos locales no sincronizados → Supabase.
  ///   2. **Pull**   — descarga gastos de Supabase que no existen localmente.
  Future<SyncResult> fullSync(String userId) async {
    // ── Fase -1: Sync categorías (pull only) ──────────────────────
    try {
      final remoteCats = await categoriasRemote.fetchCategorias(userId);
      for (final cat in remoteCats) {
        await categoriasLocal.upsertCategoria(CategoriaEntity(
          id: cat['id'] as String,
          userId: cat['user_id'] as String?,
          nombre: cat['nombre'] as String,
          icono: cat['icono'] as String?,
          color: cat['color'] as String?,
          esDefault: cat['es_default'] as bool? ?? false,
        ));
      }
      logger.i(
          'SyncService: Categorías sincronizadas: ${remoteCats.length}');
    } catch (e, st) {
      logger.e('SyncService: Error sync categorías',
          error: e, stackTrace: st);
    }

    // ── Fase 0: Eliminaciones (pendingDelete → Supabase → SQLite) ──
    int deleted = 0;
    int deleteFailed = 0;

    final pendingDeletes = await localDatasource.getPendingDeletes();

    if (pendingDeletes.isNotEmpty) {
      logger.i(
        'SyncService: Eliminando ${pendingDeletes.length} gasto(s) en la nube...',
      );
    }

    for (final row in pendingDeletes) {
      try {
        // Siempre tiene supabaseId porque deleteGasto solo hace soft-delete
        // cuando existe supabaseId
        await remoteDatasource.deleteGasto(row.supabaseId!);
        await localDatasource.hardDeleteById(row.id);
        deleted++;
        logger.d(
          'SyncService: 🗑️ Gasto ${row.supabaseId} eliminado de Supabase y SQLite.',
        );
      } catch (e, stack) {
        deleteFailed++;
        logger.e(
          'SyncService: ❌ Error al eliminar gasto #${row.id}',
          error: e,
          stackTrace: stack,
        );
      }
    }

    // ── Fase 1: Push (local → remoto) ─────────────────────────────
    final pushResult = await syncPendingGastos(userId);

    // ── Fase 2: Pull (remoto → local) ─────────────────────────────
    int pulled = 0;
    int pullFailed = 0;

    try {
      final remoteGastos = await remoteDatasource.fetchAllGastos(userId);
      logger.i(
        'SyncService: Pull → ${remoteGastos.length} gasto(s) en la nube.',
      );

      for (final remote in remoteGastos) {
        try {
          final supabaseId = remote['id'] as String;
          final exists =
              await localDatasource.existsBySupabaseId(supabaseId);

          if (!exists) {
            await localDatasource.insertFromRemote(remote);
            pulled++;
            logger.d(
              'SyncService: ⬇️ Gasto remoto $supabaseId insertado localmente.',
            );
          }
        } catch (e, stack) {
          pullFailed++;
          logger.e(
            'SyncService: ❌ Error al insertar gasto remoto',
            error: e,
            stackTrace: stack,
          );
        }
      }

      logger.i('SyncService: Pull completo → $pulled nuevo(s).');
    } catch (e, stack) {
      logger.e(
        'SyncService: ❌ Error general en fase pull',
        error: e,
        stackTrace: stack,
      );
      pullFailed++;
    }

    // ── Fase 3: Sync presupuestos ──────────────────────────────
    try {
      // Push unsynced presupuestos
      final unsyncedPresupuestos =
          await presupuestosLocal.getUnsyncedPresupuestos();
      for (final p in unsyncedPresupuestos) {
        try {
          await presupuestosRemote.upsertPresupuesto(p, userId);
          await presupuestosLocal.markAsSynced(p.id);
          logger.d('SyncService: ✅ Presupuesto ${p.id} sincronizado');
        } catch (e, st) {
          logger.e('SyncService: ❌ Error sync presupuesto',
              error: e, stackTrace: st);
        }
      }
      // Pull presupuestos del mes actual y siguiente
      final now = DateTime.now();
      for (final mes in [
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1),
      ]) {
        final remotePresupuestos =
            await presupuestosRemote.fetchPresupuestosByMes(userId, mes);
        for (final rp in remotePresupuestos) {
          await presupuestosLocal.upsertPresupuesto(PresupuestoEntity(
            id: rp['id'] as String,
            userId: rp['user_id'] as String,
            categoriaId: rp['categoria_id'] as String?,
            montoLimite: (rp['monto_limite'] as num).toDouble(),
            mes: DateTime.parse(rp['mes'] as String),
            isSynced: true,
          ));
        }
      }
      logger.i('SyncService: Presupuestos sincronizados');
    } catch (e, st) {
      logger.e('SyncService: Error sync presupuestos', error: e, stackTrace: st);
    }

    // ── Fase 4: Sync tarjetas de crédito ──────────────────────────
    await _syncTarjetas(userId);

    // ── Fase 5: Sync cuotas programadas ───────────────────────────
    await _syncCuotas();

    return SyncResult(
      total: pushResult.total,
      synced: pushResult.synced,
      failed: pushResult.failed + pullFailed + deleteFailed,
      pulled: pulled,
      deleted: deleted,
    );
  }

  // ----------------------------------------------------------------
  // Sync tarjetas de crédito (push all + pull)
  // ----------------------------------------------------------------
  Future<void> _syncTarjetas(String userId) async {
    try {
      // Push: upsert todas las tarjetas locales
      final tarjetas = await tarjetasLocal.getTarjetas();
      for (final t in tarjetas) {
        try {
          await tarjetasRemote.upsertTarjeta(t, userId);
          logger.d('SyncService: ✅ Tarjeta ${t.id} subida a Supabase');
        } catch (e, st) {
          logger.e('SyncService: ❌ Error sync tarjeta ${t.id}',
              error: e, stackTrace: st);
        }
      }

      // Delete remoto: eliminar de Supabase las tarjetas que ya no existen localmente
      final localIds = tarjetas.map((t) => t.id).toSet();
      final remotas = await tarjetasRemote.fetchTarjetas(userId);

      for (final r in remotas) {
        final id = r['id'] as String;
        if (!localIds.contains(id)) {
          // Existe en Supabase pero fue eliminada localmente → borrar remoto
          try {
            await tarjetasRemote.deleteTarjeta(id);
            logger.d('SyncService: 🗑️ Tarjeta $id eliminada de Supabase');
          } catch (e, st) {
            logger.e('SyncService: ❌ Error al eliminar tarjeta remota $id',
                error: e, stackTrace: st);
          }
        }
      }

      logger.i('SyncService: Tarjetas sincronizadas');
    } catch (e, st) {
      logger.e('SyncService: Error sync tarjetas', error: e, stackTrace: st);
    }
  }

  // ----------------------------------------------------------------
  // Sync cuotas programadas (push unsynced + pull new)
  // ----------------------------------------------------------------
  Future<void> _syncCuotas() async {
    try {
      // Push: cuotas locales no sincronizadas cuyo gasto origen ya subió
      final unsynced = await cuotasLocal.getUnsyncedCuotas();
      for (final cuota in unsynced) {
        if (cuota.gastoOrigenSupabaseId == null) {
          // El gasto padre aún no se sincronizó; intentar obtener su supabaseId
          final gastoLocal = await localDatasource
              .getGastoById(cuota.gastoOrigenId)
              .catchError((_) => null);
          if (gastoLocal?.supabaseId == null) continue;

          await cuotasLocal.updateGastoOrigenSupabaseId(
              cuota.gastoOrigenId, gastoLocal!.supabaseId!);
          continue; // Se actualizó isSynced=false; se reintentará próximo sync
        }

        try {
          final supabaseId = await cuotasRemote.upsertCuota(cuota);
          await cuotasLocal.markCuotaAsSynced(cuota.id!, supabaseId);
          logger.d(
              'SyncService: ✅ Cuota ${cuota.id} sincronizada → $supabaseId');
        } catch (e, st) {
          logger.e('SyncService: ❌ Error sync cuota ${cuota.id}',
              error: e, stackTrace: st);
        }
      }

      // Pull: cuotas remotas que no existen localmente
      final remotas = await cuotasRemote.fetchCuotas();
      for (final r in remotas) {
        try {
          await cuotasLocal.upsertFromRemote(r);
        } catch (e, st) {
          logger.e('SyncService: ❌ Error pull cuota', error: e, stackTrace: st);
        }
      }

      logger.i('SyncService: Cuotas sincronizadas');
    } catch (e, st) {
      logger.e('SyncService: Error sync cuotas', error: e, stackTrace: st);
    }
  }
}

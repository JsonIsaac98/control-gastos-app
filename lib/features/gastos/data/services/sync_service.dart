import 'package:logger/logger.dart';

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
  });

  final GastosLocalDatasource localDatasource;
  final GastosRemoteDatasource remoteDatasource;
  final Logger logger;

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
  /// Ejecuta las tres fases de sincronización en orden:
  ///   0. **Delete** — elimina de Supabase los gastos con [pendingDelete]=true,
  ///      luego los borra físicamente de SQLite.
  ///   1. **Push**   — sube gastos locales no sincronizados → Supabase.
  ///   2. **Pull**   — descarga gastos de Supabase que no existen localmente.
  ///
  /// El orden importa: las eliminaciones van primero para que el pull
  /// no vuelva a insertar registros que el usuario ya borró.
  Future<SyncResult> fullSync(String userId) async {
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

    return SyncResult(
      total: pushResult.total,
      synced: pushResult.synced,
      failed: pushResult.failed + pullFailed + deleteFailed,
      pulled: pulled,
      deleted: deleted,
    );
  }
}

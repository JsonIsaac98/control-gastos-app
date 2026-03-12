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
  });

  /// Total de registros que estaban pendientes.
  final int total;

  /// Registros sincronizados exitosamente.
  final int synced;

  /// Registros que fallaron.
  final int failed;

  bool get hasErrors => failed > 0;
  bool get allSynced => total > 0 && failed == 0;
  bool get nothingToDo => total == 0;

  @override
  String toString() =>
      'SyncResult(total: $total, synced: $synced, failed: $failed)';
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
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/logger_provider.dart';
import '../data/services/sync_service.dart';
import 'gastos_provider.dart';
import 'gastos_repository_provider.dart';

part 'sync_provider.g.dart';

// ----------------------------------------------------------------
// SyncService provider
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
SyncService syncService(SyncServiceRef ref) {
  return SyncService(
    localDatasource: ref.watch(gastosLocalDatasourceProvider),
    remoteDatasource: ref.watch(gastosRemoteDatasourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

// ----------------------------------------------------------------
// SyncNotifier — gestiona el estado de la sincronización en la UI
// ----------------------------------------------------------------
/// Estado: AsyncValue<SyncResult?>
///   - data(null)         → sin sincronización reciente
///   - loading()          → sincronización en curso
///   - data(SyncResult)   → resultado de la última sync
///   - error(e, st)       → falló (ej. sin conexión)
@riverpod
class SyncNotifier extends _$SyncNotifier {
  @override
  AsyncValue<SyncResult?> build() => const AsyncValue.data(null);

  /// Lanza la sincronización de los gastos pendientes.
  ///
  /// Solo ejecuta si hay un usuario autenticado activo.
  /// Al terminar, invalida los providers de UI para refrescar los datos.
  Future<void> syncNow() async {
    // Verificar que hay sesión activa antes de intentar sincronizar
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = AsyncValue.error(
        Exception('Debes iniciar sesión para sincronizar.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(syncServiceProvider).syncPendingGastos(userId),
    );

    // Si la sync fue exitosa, refrescar los datos en pantalla
    if (!state.hasError) {
      ref.invalidate(gastosDelMesProvider);
      ref.invalidate(dashboardResumenProvider);
    }
  }

  /// Limpia el estado para que el botón vuelva a su estado inicial.
  void reset() => state = const AsyncValue.data(null);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/logger_provider.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/services/local_auth_cache.dart';
import '../../../features/categorias/providers/categorias_provider.dart';
import '../../../features/presupuestos/providers/presupuestos_provider.dart';
import '../../../features/tarjetas/data/datasources/tarjetas_remote_datasource.dart';
import '../../../features/tarjetas/providers/tarjetas_provider.dart';
import '../data/datasources/cuotas_remote_datasource.dart';
import '../data/services/sync_service.dart';
import 'cuotas_provider.dart';
import 'gastos_provider.dart';
import 'gastos_repository_provider.dart';

part 'sync_provider.g.dart';

// ----------------------------------------------------------------
// SyncService provider
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
TarjetasRemoteDatasource tarjetasRemoteDatasource(
    TarjetasRemoteDatasourceRef ref) {
  return TarjetasRemoteDatasource(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
CuotasRemoteDatasource cuotasRemoteDatasource(CuotasRemoteDatasourceRef ref) {
  return CuotasRemoteDatasource(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
SyncService syncService(SyncServiceRef ref) {
  return SyncService(
    localDatasource: ref.watch(gastosLocalDatasourceProvider),
    remoteDatasource: ref.watch(gastosRemoteDatasourceProvider),
    logger: ref.watch(appLoggerProvider),
    categoriasLocal: ref.watch(categoriasLocalDatasourceProvider),
    categoriasRemote: ref.watch(categoriasRemoteDatasourceProvider),
    presupuestosLocal: ref.watch(presupuestosLocalDatasourceProvider),
    presupuestosRemote: ref.watch(presupuestosRemoteDatasourceProvider),
    tarjetasLocal: ref.watch(tarjetasLocalDatasourceProvider),
    tarjetasRemote: ref.watch(tarjetasRemoteDatasourceProvider),
    cuotasLocal: ref.watch(cuotasLocalDatasourceProvider),
    cuotasRemote: ref.watch(cuotasRemoteDatasourceProvider),
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

  /// Lanza la sincronización bidireccional completa (push + pull).
  ///
  /// Requiere un usuario autenticado. Primero intenta usar la sesión
  /// activa de Supabase; si no hay conexión, usa el userId del caché
  /// local para identificar al usuario.
  ///
  /// Al terminar, invalida los providers de UI para refrescar los datos.
  Future<void> syncNow() async {
    // Prioridad: sesión de Supabase → caché local (modo offline parcial)
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        LocalAuthCache.instance.userId;

    if (userId == null) {
      state = AsyncValue.error(
        Exception('Debes iniciar sesión para sincronizar.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(syncServiceProvider).fullSync(userId),
    );

    // Si la sync fue exitosa, refrescar los datos en pantalla
    if (!state.hasError) {
      ref.invalidate(gastosDelMesProvider);
      ref.invalidate(dashboardResumenProvider);
      ref.invalidate(categoriasProvider);
      ref.invalidate(presupuestosMesProvider);
      ref.invalidate(tarjetasProvider);
      ref.invalidate(todasLasCuotasProvider);
      ref.invalidate(cuotasPendientesProvider);
    }
  }

  /// Limpia el estado para que el botón vuelva a su estado inicial.
  void reset() => state = const AsyncValue.data(null);
}

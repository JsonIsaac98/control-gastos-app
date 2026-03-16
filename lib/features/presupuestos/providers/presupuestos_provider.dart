import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/datasources/presupuestos_local_datasource.dart';
import '../data/datasources/presupuestos_remote_datasource.dart';
import '../domain/entities/presupuesto_entity.dart';

part 'presupuestos_provider.g.dart';

@Riverpod(keepAlive: true)
PresupuestosLocalDatasource presupuestosLocalDatasource(
    PresupuestosLocalDatasourceRef ref) {
  return PresupuestosLocalDatasource(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
PresupuestosRemoteDatasource presupuestosRemoteDatasource(
    PresupuestosRemoteDatasourceRef ref) {
  return PresupuestosRemoteDatasource(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<PresupuestoEntity>> presupuestosMes(
    PresupuestosMesRef ref, DateTime mes) {
  return ref
      .watch(presupuestosLocalDatasourceProvider)
      .getPresupuestosByMes(mes);
}

@riverpod
class PresupuestosNotifier extends _$PresupuestosNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> guardar(PresupuestoEntity p) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(presupuestosLocalDatasourceProvider)
          .upsertPresupuesto(p),
    );
    if (!state.hasError) {
      ref.invalidate(presupuestosMesProvider);
    }
  }

  Future<void> eliminar(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(presupuestosLocalDatasourceProvider)
          .deletePresupuesto(id),
    );
    if (!state.hasError) {
      ref.invalidate(presupuestosMesProvider);
    }
  }
}

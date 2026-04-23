import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../data/datasources/tarjetas_local_datasource.dart';
import '../domain/entities/tarjeta_entity.dart';

part 'tarjetas_provider.g.dart';

@Riverpod(keepAlive: true)
TarjetasLocalDatasource tarjetasLocalDatasource(
    TarjetasLocalDatasourceRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return TarjetasLocalDatasource(db);
}

@riverpod
class Tarjetas extends _$Tarjetas {
  @override
  Future<List<TarjetaEntity>> build() async {
    return ref.watch(tarjetasLocalDatasourceProvider).getTarjetas();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(tarjetasLocalDatasourceProvider).getTarjetas(),
    );
  }

  Future<void> addTarjeta(TarjetaEntity tarjeta) async {
    await ref.read(tarjetasLocalDatasourceProvider).addTarjeta(tarjeta);
    await refresh();
  }

  Future<void> updateTarjeta(TarjetaEntity tarjeta) async {
    await ref.read(tarjetasLocalDatasourceProvider).updateTarjeta(tarjeta);
    await refresh();
  }

  Future<void> deleteTarjeta(String id) async {
    await ref.read(tarjetasLocalDatasourceProvider).deleteTarjeta(id);
    await refresh();
  }
}

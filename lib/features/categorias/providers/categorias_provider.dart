import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/datasources/categorias_local_datasource.dart';
import '../data/datasources/categorias_remote_datasource.dart';
import '../domain/entities/categoria_entity.dart';

part 'categorias_provider.g.dart';

@Riverpod(keepAlive: true)
CategoriasLocalDatasource categoriasLocalDatasource(
    CategoriasLocalDatasourceRef ref) {
  return CategoriasLocalDatasource(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
CategoriasRemoteDatasource categoriasRemoteDatasource(
    CategoriasRemoteDatasourceRef ref) {
  return CategoriasRemoteDatasource(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<CategoriaEntity>> categorias(CategoriasRef ref) {
  return ref.watch(categoriasLocalDatasourceProvider).getCategorias();
}

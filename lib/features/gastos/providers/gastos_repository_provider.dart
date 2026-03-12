import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../data/datasources/gastos_local_datasource.dart';
import '../data/repositories/gastos_repository_impl.dart';
import '../domain/repositories/gastos_repository.dart';

part 'gastos_repository_provider.g.dart';

@Riverpod(keepAlive: true)
GastosRepository gastosRepository(GastosRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final datasource = GastosLocalDatasource(db);
  return GastosRepositoryImpl(datasource);
}

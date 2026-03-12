import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/datasources/gastos_local_datasource.dart';
import '../data/datasources/gastos_remote_datasource.dart';
import '../data/repositories/gastos_repository_impl.dart';
import '../domain/repositories/gastos_repository.dart';

part 'gastos_repository_provider.g.dart';

// ----------------------------------------------------------------
// Datasource local (SQLite / Drift)
// keepAlive: true — misma instancia durante toda la sesión.
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
GastosLocalDatasource gastosLocalDatasource(GastosLocalDatasourceRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return GastosLocalDatasource(db);
}

// ----------------------------------------------------------------
// Datasource remoto (Supabase)
// keepAlive: true — misma instancia durante toda la sesión.
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
GastosRemoteDatasource gastosRemoteDatasource(GastosRemoteDatasourceRef ref) {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  return GastosRemoteDatasource(client);
}

// ----------------------------------------------------------------
// Repositorio de gastos (usa el datasource local)
// keepAlive: true — debe vivir mientras la app esté abierta.
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
GastosRepository gastosRepository(GastosRepositoryRef ref) {
  final datasource = ref.watch(gastosLocalDatasourceProvider);
  return GastosRepositoryImpl(datasource);
}

import '../../domain/entities/gasto_entity.dart';
import '../../domain/repositories/gastos_repository.dart';
import '../datasources/gastos_local_datasource.dart';

class GastosRepositoryImpl implements GastosRepository {
  GastosRepositoryImpl(this._datasource);

  final GastosLocalDatasource _datasource;

  @override
  Future<List<GastoEntity>> getGastos() => _datasource.getGastos();

  @override
  Future<List<GastoEntity>> getGastosByMonth(int year, int month) =>
      _datasource.getGastosByMonth(year, month);

  @override
  Future<double> getMonthlyTotal(int year, int month) =>
      _datasource.getMonthlyTotal(year, month);

  @override
  Future<Map<TipoPago, double>> getMonthlyTotalByTipoPago(
          int year, int month) =>
      _datasource.getMonthlyTotalByTipoPago(year, month);

  @override
  Future<GastoEntity> addGasto(GastoEntity gasto) =>
      _datasource.addGasto(gasto);

  @override
  Future<void> deleteGasto(int id) => _datasource.deleteGasto(id);

  @override
  Future<void> updateGasto(GastoEntity gasto) =>
      _datasource.updateGasto(gasto);
}

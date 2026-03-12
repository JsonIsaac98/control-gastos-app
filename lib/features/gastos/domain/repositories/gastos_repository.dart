import '../entities/gasto_entity.dart';

abstract class GastosRepository {
  /// Retorna todos los gastos ordenados por fecha descendente
  Future<List<GastoEntity>> getGastos();

  /// Retorna gastos de un mes específico
  Future<List<GastoEntity>> getGastosByMonth(int year, int month);

  /// Retorna la suma total de gastos de un mes
  Future<double> getMonthlyTotal(int year, int month);

  /// Retorna suma por tipo de pago de un mes
  Future<Map<TipoPago, double>> getMonthlyTotalByTipoPago(int year, int month);

  /// Agrega un nuevo gasto
  Future<GastoEntity> addGasto(GastoEntity gasto);

  /// Elimina un gasto por id
  Future<void> deleteGasto(int id);

  /// Actualiza un gasto existente
  Future<void> updateGasto(GastoEntity gasto);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/notification_service.dart';
import '../../gastos/providers/gastos_provider.dart';
import 'presupuestos_provider.dart';

part 'budget_alert_provider.g.dart';

@riverpod
Future<void> checkBudgetAlerts(CheckBudgetAlertsRef ref) async {
  final now = DateTime.now();
  final mes = DateTime(now.year, now.month, 1);

  final gastos = await ref.watch(gastosDelMesPorFechaProvider(mes).future);
  final presupuestos = await ref.watch(presupuestosMesProvider(mes).future);

  // Group spending by category
  final Map<String, double> gastadoPorCat = {};
  for (final g in gastos) {
    final key = g.categoriaId ?? '__none__';
    gastadoPorCat[key] = (gastadoPorCat[key] ?? 0) + g.monto;
  }

  // Check each budget
  for (final p in presupuestos) {
    final key = p.categoriaId ?? '__none__';
    final gastado = gastadoPorCat[key] ?? 0;
    final porcentaje = p.montoLimite > 0 ? gastado / p.montoLimite : 0.0;

    if (porcentaje >= 0.80) {
      await NotificationService.instance.showBudgetAlert(
        categoriaNombre: p.categoriaId ?? 'General',
        porcentaje: porcentaje,
        montoGastado: gastado,
        montoLimite: p.montoLimite,
      );
    }
  }
}

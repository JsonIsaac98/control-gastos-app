/// NotificationService — stub sin dependencias nativas.
///
/// flutter_local_notifications está desactivado temporalmente porque su AAR
/// de Android requiere core library desugaring (desugar_jdk_libs) y ese
/// artefacto no resuelve en el entorno de build actual (AGP 8.11.1 + Gradle
/// 8.14). Las alertas de presupuesto quedan silenciosas hasta reactivarlo.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  /// No-op: no hay plugin que inicializar.
  Future<void> initialize() async {}

  /// No-op: la alerta se silencia hasta que se reactive el plugin.
  Future<void> showBudgetAlert({
    required String categoriaNombre,
    required double porcentaje,
    required double montoGastado,
    required double montoLimite,
  }) async {}
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/presupuesto_entity.dart';

class PresupuestosRemoteDatasource {
  const PresupuestosRemoteDatasource(this._client);

  final SupabaseClient _client;
  static const _table = 'presupuestos';

  Future<List<Map<String, dynamic>>> fetchPresupuestosByMes(
    String userId,
    DateTime mes,
  ) async {
    final mesStr =
        DateTime(mes.year, mes.month, 1).toIso8601String().substring(0, 10);
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('mes', mesStr);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> upsertPresupuesto(PresupuestoEntity p, String userId) async {
    final mesStr =
        DateTime(p.mes.year, p.mes.month, 1).toIso8601String().substring(0, 10);
    await _client.from(_table).upsert({
      'id': p.id,
      'user_id': userId,
      'categoria_id': p.categoriaId,
      'monto_limite': p.montoLimite,
      'mes': mesStr,
    });
  }

  Future<void> deletePresupuesto(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

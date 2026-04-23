import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/tarjeta_entity.dart';

class TarjetasRemoteDatasource {
  const TarjetasRemoteDatasource(this._client);

  final SupabaseClient _client;
  static const _table = 'tarjetas_credito';

  Future<void> upsertTarjeta(TarjetaEntity tarjeta, String userId) async {
    await _client.from(_table).upsert({
      'id': tarjeta.id,
      'user_id': userId,
      'nombre': tarjeta.nombre,
      'dia_corte': tarjeta.diaCorte,
      'color': tarjeta.color,
      'is_default': tarjeta.isDefault,
      'orden': tarjeta.orden,
    });
  }

  Future<List<Map<String, dynamic>>> fetchTarjetas(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('orden');
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> deleteTarjeta(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

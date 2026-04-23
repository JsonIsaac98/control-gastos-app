import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/cuota_programada_entity.dart';

class CuotasRemoteDatasource {
  const CuotasRemoteDatasource(this._client);

  final SupabaseClient _client;
  static const _table = 'cuotas_programadas';

  /// Upsert una cuota. Requiere que el gasto origen ya esté sincronizado
  /// (gastoOrigenSupabaseId != null). Retorna el UUID asignado por Supabase.
  Future<String> upsertCuota(CuotaProgramadaEntity cuota) async {
    final payload = <String, dynamic>{
      'gasto_origen_id': cuota.gastoOrigenSupabaseId,
      'descripcion': cuota.descripcion,
      'numero_cuota': cuota.numeroCuota,
      'total_cuotas': cuota.totalCuotas,
      'monto': cuota.monto,
      'fecha_vencimiento': cuota.fechaVencimiento.toUtc().toIso8601String(),
      'is_pagado': cuota.isPagado,
      'tarjeta_id': cuota.tarjetaId,
    };

    if (cuota.fechaPagado != null) {
      payload['fecha_pagado'] = cuota.fechaPagado!.toUtc().toIso8601String();
    }

    if (cuota.supabaseId != null) {
      payload['id'] = cuota.supabaseId!;
    }

    final response = await _client
        .from(_table)
        .upsert(payload)
        .select('id')
        .single();

    return response['id'] as String;
  }

  /// Descarga todas las cuotas del usuario (RLS filtra por auth.uid()).
  Future<List<Map<String, dynamic>>> fetchCuotas() async {
    final response = await _client
        .from(_table)
        .select()
        .order('fecha_vencimiento');
    return List<Map<String, dynamic>>.from(response as List);
  }
}

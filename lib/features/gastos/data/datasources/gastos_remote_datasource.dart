import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/gasto_entity.dart';

/// Datasource remoto para gastos en Supabase (PostgreSQL).
///
/// Toda escritura requiere un userId autenticado; Supabase valida
/// la identidad adicionalmente vía Row Level Security (RLS).
class GastosRemoteDatasource {
  const GastosRemoteDatasource(this._client);

  final SupabaseClient _client;
  static const _table = 'gastos';

  // ----------------------------------------------------------------
  // Upsert (insertar o actualizar) un gasto en Supabase
  // ----------------------------------------------------------------
  /// Envía un gasto a Supabase adjuntando el UID del usuario.
  ///
  /// - Si [gasto.supabaseId] es null → INSERT (nuevo registro).
  /// - Si [gasto.supabaseId] tiene valor → UPDATE del existente.
  ///
  /// Retorna el UUID que Supabase asignó al registro.
  Future<String> upsertGasto(GastoEntity gasto, String userId) async {
    final payload = {
      'user_id': userId,
      'descripcion': gasto.descripcion,
      'monto': gasto.monto,
      'tipo_pago': gasto.tipoPago.valor,
      // Supabase almacena fechas en UTC
      'fecha': gasto.fecha.toUtc().toIso8601String(),
      'created_at':
          (gasto.createdAt ?? DateTime.now()).toUtc().toIso8601String(),
      'categoria_id': gasto.categoriaId,
    };

    // Si el registro ya fue subido antes, incluir el UUID para upsert
    if (gasto.supabaseId != null) {
      payload['id'] = gasto.supabaseId!;
    }

    final response = await _client
        .from(_table)
        .upsert(payload)
        .select('id') // Solo necesitamos el id de vuelta
        .single();

    return response['id'] as String;
  }

  // ----------------------------------------------------------------
  // Eliminar un gasto en Supabase (por UUID)
  // ----------------------------------------------------------------
  /// Elimina el registro remoto identificado por [supabaseId].
  /// RLS garantiza que solo el propietario puede borrarlo.
  Future<void> deleteGasto(String supabaseId) async {
    await _client.from(_table).delete().eq('id', supabaseId);
  }

  // ----------------------------------------------------------------
  // Fetch de todos los gastos del usuario (para pull sync)
  // ----------------------------------------------------------------
  /// Descarga todos los gastos del usuario desde Supabase, ordenados
  /// por fecha descendente.
  ///
  /// Retorna una lista de mapas con los datos crudos de la nube.
  /// RLS asegura que solo se devuelven los registros del [userId].
  Future<List<Map<String, dynamic>>> fetchAllGastos(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('fecha', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }
}

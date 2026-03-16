import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/categoria_entity.dart';

class CategoriasRemoteDatasource {
  const CategoriasRemoteDatasource(this._client);

  final SupabaseClient _client;
  static const _table = 'categorias';

  /// Obtiene todas las categorías del usuario (incluyendo las por defecto
  /// donde user_id es null).
  Future<List<Map<String, dynamic>>> fetchCategorias(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .or('user_id.eq.$userId,user_id.is.null')
        .order('nombre', ascending: true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Crea o actualiza una categoría en Supabase.
  /// Retorna el UUID asignado por Supabase.
  Future<String> upsertCategoria(CategoriaEntity c, String userId) async {
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'nombre': c.nombre,
      'icono': c.icono,
      'color': c.color,
      'es_default': false,
    };
    if (c.id.isNotEmpty) payload['id'] = c.id;

    final response =
        await _client.from(_table).upsert(payload).select('id').single();
    return response['id'] as String;
  }

  Future<void> deleteCategoria(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

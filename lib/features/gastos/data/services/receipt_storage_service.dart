// TODO: Foto de recibos — desactivado temporalmente.
// Para reactivar: descomentar el bloque, añadir image_picker en pubspec.yaml
// y crear el bucket "recibos" en Supabase Storage.

/*
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Gestiona subida/borrado de fotos de recibos en Supabase Storage.
/// Path: recibos/{userId}/{gastoTimestamp}.jpg
class ReceiptStorageService {
  const ReceiptStorageService(this._client);
  final SupabaseClient _client;
  static const _bucket = 'recibos';

  /// Sube [file] y retorna la URL pública firmada (válida 10 años).
  Future<String> uploadReceipt({
    required String userId,
    required File file,
    String? existingUrl, // si ya había una foto, la borra primero
  }) async {
    if (existingUrl != null) {
      await deleteReceipt(existingUrl);
    }
    final ext = file.path.split('.').last.toLowerCase();
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from(_bucket).upload(path, file,
        fileOptions: const FileOptions(upsert: true));
    // Signed URL válida 10 años
    final signedUrl = await _client.storage
        .from(_bucket)
        .createSignedUrl(path, 60 * 60 * 24 * 3650);
    return signedUrl;
  }

  /// Borra el archivo de Storage dado su URL firmada.
  Future<void> deleteReceipt(String signedUrl) async {
    try {
      final uri = Uri.parse(signedUrl);
      final segments = uri.pathSegments;
      // Path starts after 'object/sign/{bucket}/'
      final bucketIndex = segments.indexOf(_bucket);
      if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
        final path = segments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(_bucket).remove([path]);
      }
    } catch (_) {
      // Silently fail — photo might already be deleted
    }
  }
}
*/

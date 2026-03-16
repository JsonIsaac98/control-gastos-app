// TODO: Foto de recibos — desactivado temporalmente.
// Para reactivar: descomentar, añadir image_picker en pubspec.yaml y
// ejecutar: flutter pub run build_runner build --delete-conflicting-outputs

/*
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/supabase_provider.dart';
import '../data/services/receipt_storage_service.dart';

part 'receipt_storage_provider.g.dart';

@Riverpod(keepAlive: true)
ReceiptStorageService receiptStorageService(Ref ref) {
  return ReceiptStorageService(ref.watch(supabaseClientProvider));
}
*/

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Provee la instancia singleton del cliente de Supabase.
///
/// keepAlive: true — debe vivir durante toda la sesión de la app,
/// igual que appDatabaseProvider.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  // Supabase.initialize() ya fue llamado en bootstrap.dart antes de runApp,
  // por lo que esta instancia siempre estará disponible.
  return Supabase.instance.client;
}

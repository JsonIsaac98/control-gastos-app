import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/local_auth_cache.dart';
import 'app.dart';

Future<void> bootstrap() async {
  // 1. Cargar variables de entorno desde el asset .env
  //    Las credenciales reales nunca deben estar en el código fuente.
  await dotenv.load(fileName: '.env');

  // 2. Inicializar Supabase con las credenciales del .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    // debug: true, // habilitar solo en desarrollo
  );

  // 3. Cargar caché de sesión local (userId + email, sin contraseña).
  //    Se carga ANTES de runApp para que el router ya conozca el estado
  //    de autenticación offline desde el primer frame.
  await LocalAuthCache.instance.loadFromPrefs();

  // 4. Lanzar la app dentro de ProviderScope (único en toda la app)
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

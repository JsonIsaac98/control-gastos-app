# Mobile - Core Flutter Reutilizable

Proyecto base en Flutter diseñado como Core reutilizable para múltiples POCs comerciales. Utiliza Riverpod 2 con anotaciones y code generation como estándar obligatorio de manejo de estado.

## 🎯 Objetivos del Core

- ✅ Arquitectura limpia y modular
- ✅ Reutilización total entre proyectos
- ✅ Preparado para escalar de POC a producto
- ✅ Offline-first con Drift
- ✅ Fácil de clonar y rebrandear

## 📋 Requisitos Técnicos

### Dependencias Obligatorias

- `flutter_riverpod: ^2.6.1` - Manejo de estado
- `riverpod: ^2.6.1` - Core de Riverpod
- `riverpod_annotation: ^2.6.1` - Anotaciones para code generation
- `riverpod_generator: ^2.6.2` - Generador de código
- `build_runner: ^2.4.13` - Ejecutor de generadores
- `go_router: ^14.6.2` - Routing declarativo
- `dio: ^5.7.0` - Cliente HTTP
- `drift: ^2.18.0` - Base de datos offline-first
- `freezed: ^2.4.7` - Estados inmutables
- `logger: ^2.4.0` - Logging estructurado

## 🏗️ Estructura del Proyecto

```
lib/
├── app/
│   ├── app.dart              # Widget raíz de la aplicación
│   └── bootstrap.dart        # Inicialización de la app
├── core/
│   ├── config/
│   │   ├── env.dart          # Variables de entorno
│   │   └── app_config.dart   # Configuración con feature flags
│   ├── providers/
│   │   ├── dio_provider.dart      # Provider de Dio HTTP
│   │   ├── database_provider.dart # Provider de base de datos
│   │   └── logger_provider.dart   # Provider de logger
│   ├── router/
│   │   └── app_router.dart   # Configuración de rutas
│   ├── theme/
│   │   ├── app_theme.dart    # Tema de la aplicación
│   │   ├── colors.dart       # Paleta de colores
│   │   └── typography.dart   # Tipografía
│   └── utils/
│       ├── extensions/       # Extensiones útiles
│       ├── errors/           # Manejo de errores
│       └── validators.dart   # Validadores reutilizables
└── features/
    └── example/              # Feature de ejemplo
        ├── data/             # Capa de datos
        ├── domain/           # Capa de dominio
        ├── presentation/    # Capa de presentación
        └── providers/       # Providers de la feature
```

## 🚀 Inicio Rápido

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Generar Código

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Para desarrollo con watch mode:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 3. Ejecutar la Aplicación

```bash
flutter run
```

## 📖 Convenciones de Riverpod

### Reglas Obligatorias

1. **Usar exclusivamente anotaciones `@riverpod` y `@Riverpod`**
2. **Prohibido ProviderScope anidados** - Solo uno en `bootstrap.dart`
3. **Providers separados por feature o core**
4. **Repositories expuestos como providers**
5. **AsyncNotifier para llamadas a API o DB**
6. **Notifier para estado sincrónico**
7. **keepAlive solo para sesión, config y DB**

### Convenciones de Nomenclatura

- Providers terminan en `Provider`
- Repositories terminan en `RepositoryProvider`
- Un provider por archivo
- Estados inmutables (usar Freezed)
- No lógica de UI en providers

### Ejemplo de Provider con AsyncNotifier

```dart
@riverpod
class Examples extends _$Examples {
  @override
  Future<List<ExampleEntity>> build() async {
    final repository = ref.watch(exampleRepositoryProvider);
    return repository.getExamples();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(exampleRepositoryProvider);
      return repository.getExamples();
    });
  }
}
```

## 🔧 Configuración

### Variables de Entorno

Edita `lib/core/config/env.dart` para configurar:

- `apiBaseUrl` - URL base de la API
- `environment` - Entorno (dev, staging, prod)
- `httpTimeout` - Timeout para peticiones HTTP
- `debugMode` - Modo debug

### Feature Flags

Configura los feature flags en `appConfigProvider`:

```dart
enableAnalytics: false,
enableCrashReporting: false,
enableOfflineMode: true,
enableBetaFeatures: false,
```

## 🗄️ Base de Datos (Drift)

Para agregar tablas, edita `lib/core/providers/database_provider.dart`:

```dart
class MyTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

@DriftDatabase(tables: [MyTable])
class AppDatabase extends _$AppDatabase {
  // ...
}
```

Luego ejecuta `build_runner` para generar el código.

## 🎨 Personalización (Rebranding)

### Colores

Edita `lib/core/theme/colors.dart` para cambiar la paleta de colores.

### Tipografía

Edita `lib/core/theme/typography.dart` para cambiar los estilos de texto.

### Tema

Edita `lib/core/theme/app_theme.dart` para personalizar el tema completo.

## 📝 Agregar una Nueva Feature

1. Crear estructura de carpetas en `lib/features/nueva_feature/`:
   - `data/` - Datasources, models, repositories
   - `domain/` - Entities, repositories (interfaces)
   - `presentation/` - Pages, widgets
   - `providers/` - Providers de la feature

2. Crear el repositorio provider:
```dart
@riverpod
ExampleRepository exampleRepository(Ref ref) {
  final remoteDataSource = ref.watch(exampleRemoteDataSourceProvider);
  return ExampleRepositoryImpl(remoteDataSource);
}
```

3. Crear el provider de estado:
```dart
@riverpod
class Examples extends _$Examples {
  @override
  Future<List<ExampleEntity>> build() async {
    // Implementación
  }
}
```

4. Agregar la ruta en `lib/core/router/app_router.dart`

5. Ejecutar `build_runner` para generar código

## 🧪 Testing

Ejecutar tests:

```bash
flutter test
```

## 📦 Build

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🔍 Troubleshooting

### Error: "Target of URI hasn't been generated"

Ejecuta `build_runner`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: "Undefined class 'Ref'"

Asegúrate de tener `riverpod` en `pubspec.yaml` y ejecuta:

```bash
flutter pub get
```

## 📚 Recursos

- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Freezed Documentation](https://pub.dev/packages/freezed)

## 📄 Licencia

Este proyecto es un template base para uso interno en POCs comerciales.

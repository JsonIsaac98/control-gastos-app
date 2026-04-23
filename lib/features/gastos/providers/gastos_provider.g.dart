// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gastos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gastosDelMesPorFechaHash() =>
    r'571ebaab18bd3c7198585f34033dc0ba344ad2ef';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Lista de gastos de un mes específico (para uso en reportes y presupuestos).
/// Acepta un DateTime como parámetro para consultar cualquier mes.
///
/// Copied from [gastosDelMesPorFecha].
@ProviderFor(gastosDelMesPorFecha)
const gastosDelMesPorFechaProvider = GastosDelMesPorFechaFamily();

/// Lista de gastos de un mes específico (para uso en reportes y presupuestos).
/// Acepta un DateTime como parámetro para consultar cualquier mes.
///
/// Copied from [gastosDelMesPorFecha].
class GastosDelMesPorFechaFamily extends Family<AsyncValue<List<GastoEntity>>> {
  /// Lista de gastos de un mes específico (para uso en reportes y presupuestos).
  /// Acepta un DateTime como parámetro para consultar cualquier mes.
  ///
  /// Copied from [gastosDelMesPorFecha].
  const GastosDelMesPorFechaFamily();

  /// Lista de gastos de un mes específico (para uso en reportes y presupuestos).
  /// Acepta un DateTime como parámetro para consultar cualquier mes.
  ///
  /// Copied from [gastosDelMesPorFecha].
  GastosDelMesPorFechaProvider call(
    DateTime mes,
  ) {
    return GastosDelMesPorFechaProvider(
      mes,
    );
  }

  @override
  GastosDelMesPorFechaProvider getProviderOverride(
    covariant GastosDelMesPorFechaProvider provider,
  ) {
    return call(
      provider.mes,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gastosDelMesPorFechaProvider';
}

/// Lista de gastos de un mes específico (para uso en reportes y presupuestos).
/// Acepta un DateTime como parámetro para consultar cualquier mes.
///
/// Copied from [gastosDelMesPorFecha].
class GastosDelMesPorFechaProvider
    extends AutoDisposeFutureProvider<List<GastoEntity>> {
  /// Lista de gastos de un mes específico (para uso en reportes y presupuestos).
  /// Acepta un DateTime como parámetro para consultar cualquier mes.
  ///
  /// Copied from [gastosDelMesPorFecha].
  GastosDelMesPorFechaProvider(
    DateTime mes,
  ) : this._internal(
          (ref) => gastosDelMesPorFecha(
            ref as GastosDelMesPorFechaRef,
            mes,
          ),
          from: gastosDelMesPorFechaProvider,
          name: r'gastosDelMesPorFechaProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$gastosDelMesPorFechaHash,
          dependencies: GastosDelMesPorFechaFamily._dependencies,
          allTransitiveDependencies:
              GastosDelMesPorFechaFamily._allTransitiveDependencies,
          mes: mes,
        );

  GastosDelMesPorFechaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mes,
  }) : super.internal();

  final DateTime mes;

  @override
  Override overrideWith(
    FutureOr<List<GastoEntity>> Function(GastosDelMesPorFechaRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GastosDelMesPorFechaProvider._internal(
        (ref) => create(ref as GastosDelMesPorFechaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mes: mes,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GastoEntity>> createElement() {
    return _GastosDelMesPorFechaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GastosDelMesPorFechaProvider && other.mes == mes;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mes.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GastosDelMesPorFechaRef
    on AutoDisposeFutureProviderRef<List<GastoEntity>> {
  /// The parameter `mes` of this provider.
  DateTime get mes;
}

class _GastosDelMesPorFechaProviderElement
    extends AutoDisposeFutureProviderElement<List<GastoEntity>>
    with GastosDelMesPorFechaRef {
  _GastosDelMesPorFechaProviderElement(super.provider);

  @override
  DateTime get mes => (origin as GastosDelMesPorFechaProvider).mes;
}

String _$dashboardResumenHash() => r'3ec19d2f93512fbb90dcb496e557dd909e820e65';

/// Resumen del dashboard para el mes seleccionado
///
/// Copied from [dashboardResumen].
@ProviderFor(dashboardResumen)
final dashboardResumenProvider =
    AutoDisposeFutureProvider<DashboardResumen>.internal(
  dashboardResumen,
  name: r'dashboardResumenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardResumenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardResumenRef = AutoDisposeFutureProviderRef<DashboardResumen>;
String _$selectedMonthHash() => r'50e2019bc21cfe85b0e0d18889ab420dc0eaf97b';

/// Estado del mes seleccionado para filtrar gastos
///
/// Copied from [SelectedMonth].
@ProviderFor(SelectedMonth)
final selectedMonthProvider =
    AutoDisposeNotifierProvider<SelectedMonth, DateTime>.internal(
  SelectedMonth.new,
  name: r'selectedMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedMonth = AutoDisposeNotifier<DateTime>;
String _$gastosDelMesHash() => r'c99b120c37eb7db21c802e7dedaeb864ec568199';

/// Lista de gastos del mes seleccionado
///
/// Copied from [GastosDelMes].
@ProviderFor(GastosDelMes)
final gastosDelMesProvider =
    AutoDisposeAsyncNotifierProvider<GastosDelMes, List<GastoEntity>>.internal(
  GastosDelMes.new,
  name: r'gastosDelMesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gastosDelMesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GastosDelMes = AutoDisposeAsyncNotifier<List<GastoEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

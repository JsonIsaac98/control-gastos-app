// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gastos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardResumenHash() => r'db7ac9b71f4d18e79ed5b36c6a36bfaf53ac53d8';

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
String _$gastosDelMesHash() => r'036238ff2a0ab0474ee3acac917f8c8f668e568a';

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

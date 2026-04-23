// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuotas_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cuotasLocalDatasourceHash() =>
    r'5f7aef8afa1bc2ec1aab4d23e44471fdc2aa69f8';

/// See also [cuotasLocalDatasource].
@ProviderFor(cuotasLocalDatasource)
final cuotasLocalDatasourceProvider = Provider<CuotasLocalDatasource>.internal(
  cuotasLocalDatasource,
  name: r'cuotasLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cuotasLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CuotasLocalDatasourceRef = ProviderRef<CuotasLocalDatasource>;
String _$todasLasCuotasHash() => r'f3a28788e155a9d8c73a6a1e44bba549e33f0eb4';

/// See also [todasLasCuotas].
@ProviderFor(todasLasCuotas)
final todasLasCuotasProvider =
    AutoDisposeFutureProvider<List<CuotaProgramadaEntity>>.internal(
  todasLasCuotas,
  name: r'todasLasCuotasProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todasLasCuotasHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodasLasCuotasRef
    = AutoDisposeFutureProviderRef<List<CuotaProgramadaEntity>>;
String _$cuotasPendientesHash() => r'4a89dfbd5a11e68f83da86bfe41d6044c4266b39';

/// See also [CuotasPendientes].
@ProviderFor(CuotasPendientes)
final cuotasPendientesProvider = AutoDisposeAsyncNotifierProvider<
    CuotasPendientes, List<CuotaProgramadaEntity>>.internal(
  CuotasPendientes.new,
  name: r'cuotasPendientesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cuotasPendientesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CuotasPendientes
    = AutoDisposeAsyncNotifier<List<CuotaProgramadaEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

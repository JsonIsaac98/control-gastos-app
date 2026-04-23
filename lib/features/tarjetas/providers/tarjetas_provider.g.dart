// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarjetas_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tarjetasLocalDatasourceHash() =>
    r'a3487b2bb2a949b4ad99e52623e94275301cc124';

/// See also [tarjetasLocalDatasource].
@ProviderFor(tarjetasLocalDatasource)
final tarjetasLocalDatasourceProvider =
    Provider<TarjetasLocalDatasource>.internal(
  tarjetasLocalDatasource,
  name: r'tarjetasLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tarjetasLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TarjetasLocalDatasourceRef = ProviderRef<TarjetasLocalDatasource>;
String _$tarjetasHash() => r'c4b1235dbf22a0f84800f9bd579a1cb2d2a0e55a';

/// See also [Tarjetas].
@ProviderFor(Tarjetas)
final tarjetasProvider =
    AutoDisposeAsyncNotifierProvider<Tarjetas, List<TarjetaEntity>>.internal(
  Tarjetas.new,
  name: r'tarjetasProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tarjetasHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Tarjetas = AutoDisposeAsyncNotifier<List<TarjetaEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

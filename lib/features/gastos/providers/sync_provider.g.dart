// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tarjetasRemoteDatasourceHash() =>
    r'0477b9f6321fa0287d2f955f8765371db7af9dc1';

/// See also [tarjetasRemoteDatasource].
@ProviderFor(tarjetasRemoteDatasource)
final tarjetasRemoteDatasourceProvider =
    Provider<TarjetasRemoteDatasource>.internal(
  tarjetasRemoteDatasource,
  name: r'tarjetasRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tarjetasRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TarjetasRemoteDatasourceRef = ProviderRef<TarjetasRemoteDatasource>;
String _$cuotasRemoteDatasourceHash() =>
    r'8e630032ef2f729b8e4e161678465a75af4bbe95';

/// See also [cuotasRemoteDatasource].
@ProviderFor(cuotasRemoteDatasource)
final cuotasRemoteDatasourceProvider =
    Provider<CuotasRemoteDatasource>.internal(
  cuotasRemoteDatasource,
  name: r'cuotasRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cuotasRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CuotasRemoteDatasourceRef = ProviderRef<CuotasRemoteDatasource>;
String _$syncServiceHash() => r'd3cf587d8030b4c5b33f51f158806b0cbc8bde20';

/// See also [syncService].
@ProviderFor(syncService)
final syncServiceProvider = Provider<SyncService>.internal(
  syncService,
  name: r'syncServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncServiceRef = ProviderRef<SyncService>;
String _$syncNotifierHash() => r'921b6587d5d07b751753767cf4e332e5de48638b';

/// Estado: AsyncValue<SyncResult?>
///   - data(null)         → sin sincronización reciente
///   - loading()          → sincronización en curso
///   - data(SyncResult)   → resultado de la última sync
///   - error(e, st)       → falló (ej. sin conexión)
///
/// Copied from [SyncNotifier].
@ProviderFor(SyncNotifier)
final syncNotifierProvider =
    AutoDisposeNotifierProvider<SyncNotifier, AsyncValue<SyncResult?>>.internal(
  SyncNotifier.new,
  name: r'syncNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncNotifier = AutoDisposeNotifier<AsyncValue<SyncResult?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

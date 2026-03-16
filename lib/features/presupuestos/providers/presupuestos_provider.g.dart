// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuestos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presupuestosLocalDatasourceHash() =>
    r'392d0314d8a6c0d17760ff55bd217b5a517c0022';

/// See also [presupuestosLocalDatasource].
@ProviderFor(presupuestosLocalDatasource)
final presupuestosLocalDatasourceProvider =
    Provider<PresupuestosLocalDatasource>.internal(
  presupuestosLocalDatasource,
  name: r'presupuestosLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$presupuestosLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PresupuestosLocalDatasourceRef
    = ProviderRef<PresupuestosLocalDatasource>;
String _$presupuestosRemoteDatasourceHash() =>
    r'b238694a5eeab2ae61b9318c97ca4cbf5faf540a';

/// See also [presupuestosRemoteDatasource].
@ProviderFor(presupuestosRemoteDatasource)
final presupuestosRemoteDatasourceProvider =
    Provider<PresupuestosRemoteDatasource>.internal(
  presupuestosRemoteDatasource,
  name: r'presupuestosRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$presupuestosRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PresupuestosRemoteDatasourceRef
    = ProviderRef<PresupuestosRemoteDatasource>;
String _$presupuestosMesHash() => r'1844e789bac767e1b779b0a3c6da01005731dfee';

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

/// See also [presupuestosMes].
@ProviderFor(presupuestosMes)
const presupuestosMesProvider = PresupuestosMesFamily();

/// See also [presupuestosMes].
class PresupuestosMesFamily
    extends Family<AsyncValue<List<PresupuestoEntity>>> {
  /// See also [presupuestosMes].
  const PresupuestosMesFamily();

  /// See also [presupuestosMes].
  PresupuestosMesProvider call(
    DateTime mes,
  ) {
    return PresupuestosMesProvider(
      mes,
    );
  }

  @override
  PresupuestosMesProvider getProviderOverride(
    covariant PresupuestosMesProvider provider,
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
  String? get name => r'presupuestosMesProvider';
}

/// See also [presupuestosMes].
class PresupuestosMesProvider
    extends AutoDisposeFutureProvider<List<PresupuestoEntity>> {
  /// See also [presupuestosMes].
  PresupuestosMesProvider(
    DateTime mes,
  ) : this._internal(
          (ref) => presupuestosMes(
            ref as PresupuestosMesRef,
            mes,
          ),
          from: presupuestosMesProvider,
          name: r'presupuestosMesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$presupuestosMesHash,
          dependencies: PresupuestosMesFamily._dependencies,
          allTransitiveDependencies:
              PresupuestosMesFamily._allTransitiveDependencies,
          mes: mes,
        );

  PresupuestosMesProvider._internal(
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
    FutureOr<List<PresupuestoEntity>> Function(PresupuestosMesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PresupuestosMesProvider._internal(
        (ref) => create(ref as PresupuestosMesRef),
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
  AutoDisposeFutureProviderElement<List<PresupuestoEntity>> createElement() {
    return _PresupuestosMesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PresupuestosMesProvider && other.mes == mes;
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
mixin PresupuestosMesRef
    on AutoDisposeFutureProviderRef<List<PresupuestoEntity>> {
  /// The parameter `mes` of this provider.
  DateTime get mes;
}

class _PresupuestosMesProviderElement
    extends AutoDisposeFutureProviderElement<List<PresupuestoEntity>>
    with PresupuestosMesRef {
  _PresupuestosMesProviderElement(super.provider);

  @override
  DateTime get mes => (origin as PresupuestosMesProvider).mes;
}

String _$presupuestosNotifierHash() =>
    r'd2794e31afe6f969adb3b22835d52fb31bf3e882';

/// See also [PresupuestosNotifier].
@ProviderFor(PresupuestosNotifier)
final presupuestosNotifierProvider = AutoDisposeNotifierProvider<
    PresupuestosNotifier, AsyncValue<void>>.internal(
  PresupuestosNotifier.new,
  name: r'presupuestosNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$presupuestosNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PresupuestosNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

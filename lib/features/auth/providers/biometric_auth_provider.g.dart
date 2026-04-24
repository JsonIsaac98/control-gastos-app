// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$biometricAuthRepositoryHash() =>
    r'89f7318d252ad75fb768fdc95e292457a473c8fa';

/// See also [biometricAuthRepository].
@ProviderFor(biometricAuthRepository)
final biometricAuthRepositoryProvider =
    Provider<BiometricAuthRepository>.internal(
  biometricAuthRepository,
  name: r'biometricAuthRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricAuthRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BiometricAuthRepositoryRef = ProviderRef<BiometricAuthRepository>;
String _$biometricAvailableHash() =>
    r'54e39b1e5be04170447b32db3890c2ee0c91ecf5';

/// See also [biometricAvailable].
@ProviderFor(biometricAvailable)
final biometricAvailableProvider = AutoDisposeFutureProvider<bool>.internal(
  biometricAvailable,
  name: r'biometricAvailableProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricAvailableHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BiometricAvailableRef = AutoDisposeFutureProviderRef<bool>;
String _$biometricHasStoredSessionHash() =>
    r'7bbcad69ae7a8ed8b63d173fc000a46dd57c6375';

/// See also [biometricHasStoredSession].
@ProviderFor(biometricHasStoredSession)
final biometricHasStoredSessionProvider =
    AutoDisposeFutureProvider<bool>.internal(
  biometricHasStoredSession,
  name: r'biometricHasStoredSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricHasStoredSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BiometricHasStoredSessionRef = AutoDisposeFutureProviderRef<bool>;
String _$biometricEnabledHash() => r'45c4fe50f44355ccbecc3f3489a62c8f092694a5';

/// See also [BiometricEnabled].
@ProviderFor(BiometricEnabled)
final biometricEnabledProvider =
    AsyncNotifierProvider<BiometricEnabled, bool>.internal(
  BiometricEnabled.new,
  name: r'biometricEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BiometricEnabled = AsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

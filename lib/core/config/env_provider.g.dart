// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$environmentHash() => r'079a6ef577fee6cb1d8ff3553d1055d592501068';

/// Environment configuration that can be switched at runtime (all build modes)
/// Matches web pattern: test.shahirizadameatmarket.com vs shahirizadameatmarket.com
///
/// Copied from [Environment].
@ProviderFor(Environment)
final environmentProvider =
    NotifierProvider<Environment, AppEnvironment>.internal(
      Environment.new,
      name: r'environmentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$environmentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Environment = Notifier<AppEnvironment>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

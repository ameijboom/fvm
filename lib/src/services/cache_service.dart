import 'dart:io';

import 'package:fvm/exceptions.dart';
import 'package:fvm/src/services/base_service.dart';
import 'package:fvm/src/utils/context.dart';
import 'package:fvm/src/utils/extensions.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as path;

import '../models/cache_flutter_version_model.dart';
import '../models/flutter_version_model.dart';

enum CacheIntegrity {
  valid,
  invalid,
  versionMismatch,
}

/// This class provides methods to manage the local cache of Flutter SDK versions.
class CacheService extends ContextService {
  const CacheService(super.context);

  /// Verifies the executability of a cached Flutter SDK version.
  /// Returns true if the cache contains an executable Flutter SDK version, otherwise false.
  ///
  /// [version] - The cached Flutter SDK version to verify.
  Future<bool> _verifyIsExecutable(CacheFlutterVersion version) async {
    final binExists = File(version.flutterExec).existsSync();
    return binExists && await isExecutable(version.flutterExec);
  }

  /// Checks if the cached version name matches the actual Flutter SDK version.
  /// Returns true for channel versions or if the SDK version is unavailable. Otherwise,
  /// returns true if the version names match.
  ///
  /// [version] - The cached Flutter SDK version to verify.
  bool _verifyVersionMatch(CacheFlutterVersion version) {
    if (version.isChannel) return true;
    if (version.flutterSdkVersion == null) return true;
    return version.flutterSdkVersion == version.version;
  }

  /// Gets an instance of [CacheService] from the current context.
  /// This static getter allows for easy access to the cache service from anywhere in the app.
  static CacheService get fromContext => getProvider();

  /// Retrieves a cached Flutter SDK version as a [CacheFlutterVersion].
  /// If the specified version is not found in the cache, this method returns null.
  ///
  /// [version] - The Flutter SDK version to retrieve from the cache.
  CacheFlutterVersion? getVersion(FlutterVersion version) {
    final versionDir = getVersionCacheDir(version.name);
    if (!versionDir.existsSync()) return null;
    return CacheFlutterVersion(version, directory: versionDir.path);
  }

  /// Lists all installed Flutter SDK versions from the cache.
  /// This asynchronous method returns a list of [CacheFlutterVersion] objects representing
  /// all the versions available in the cache. If no versions are cached, it returns an empty list.
  Future<List<CacheFlutterVersion>> getAllVersions() async {
    final versionsDir = Directory(context.versionsCachePath);
    if (!await versionsDir.exists()) return [];

    final versions = await versionsDir.list().toList();
    final cacheVersions = <CacheFlutterVersion>[];

    for (var version in versions) {
      if (version.path.isDir()) {
        final name = path.basename(version.path);
        final cacheVersion = getVersion(FlutterVersion.parse(name));
        if (cacheVersion != null) {
          cacheVersions.add(cacheVersion);
        }
      }
    }

    cacheVersions.sort((a, b) => a.compareTo(b));
    return cacheVersions.reversed.toList();
  }

  /// Removes a specific version of the Flutter SDK from the cache.
  /// This method deletes the directory containing the specified version.
  ///
  /// [version] - The version of the Flutter SDK to remove from the cache.
  void remove(FlutterVersion version) {
    final versionDir = getVersionCacheDir(version.name);
    if (versionDir.existsSync()) versionDir.deleteSync(recursive: true);
  }

  /// Creates and returns a [Directory] object for the cache directory of a specific version.
  ///
  /// [version] - The version for which to get the cache directory.
  Directory getVersionCacheDir(String version) {
    return Directory(path.join(context.versionsCachePath, version));
  }

  /// Verifies the integrity of the cached Flutter SDK version.
  /// Returns a [CacheIntegrity] enum value indicating the state of the cache:
  /// valid, invalid, or a version mismatch.
  ///
  /// [version] - The cached Flutter SDK version to verify.
  Future<CacheIntegrity> verifyCacheIntegrity(
    CacheFlutterVersion version,
  ) async {
    final isExecutable = await _verifyIsExecutable(version);
    final versionsMatch = _verifyVersionMatch(version);

    if (!isExecutable) return CacheIntegrity.invalid;
    if (!versionsMatch) return CacheIntegrity.versionMismatch;
    return CacheIntegrity.valid;
  }

  /// Moves a cached Flutter SDK version to a directory named after its SDK version.
  /// This method is used to reorganize the cache based on the actual SDK versions.
  /// Throws [AppException] if the SDK version is not valid.
  ///
  /// [version] - The cached Flutter SDK version to move.
  void moveToSdkVersionDiretory(CacheFlutterVersion version) {
    final sdkVersion = version.flutterSdkVersion;
    if (sdkVersion == null) {
      throw AppException(
        'Cannot move to SDK version directory without a valid version',
      );
    }
    final versionDir = Directory(version.directory);
    final newDir = getVersionCacheDir(sdkVersion);

    if (newDir.existsSync()) newDir.deleteSync(recursive: true);
    if (versionDir.existsSync()) versionDir.renameSync(newDir.path);
  }
}

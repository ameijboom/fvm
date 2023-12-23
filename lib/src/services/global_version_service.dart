import 'dart:io';

import 'package:fvm/src/models/cache_flutter_version_model.dart';
import 'package:fvm/src/models/flutter_version_model.dart';
import 'package:fvm/src/services/base_service.dart';
import 'package:fvm/src/services/cache_service.dart';
import 'package:fvm/src/utils/context.dart';
import 'package:fvm/src/utils/extensions.dart';
import 'package:path/path.dart' as path;

/// Service for managing global Flutter SDK versions.
class GlobalVersionService extends ContextService {
  /// Constructs the GlobalVersionService with the given context.
  const GlobalVersionService(super.context);

  /// Provides an instance of GlobalVersionService from the given context.
  static GlobalVersionService get fromContext =>
      getProvider<GlobalVersionService>();

  /// Sets the specified [CacheFlutterVersion] as the global Flutter SDK version.
  /// It creates a symbolic link in the file system to the version's directory.
  ///
  /// [version] - The Flutter SDK version to set as global.
  void setGlobal(CacheFlutterVersion version) {
    context.globalCacheLink.link.createLink(version.directory);
  }

  /// Private getter to obtain the symbolic link to the global cache.
  Link get _globalCacheLink => Link(context.globalCacheLink);

  /// Retrieves the global Flutter SDK version, if set.
  /// Returns null if no global version is configured.
  /// Utilizes symbolic links to determine the global version.
  CacheFlutterVersion? getGlobal() {
    if (!_globalCacheLink.existsSync()) return null;
    // Get directory name
    final version = path.basename(_globalCacheLink.targetSync());
    // Make sure it's a valid version
    final validVersion = FlutterVersion.parse(version);
    // Verify version is cached
    return CacheService(context).getVersion(validVersion);
  }

  /// Checks if the specified [CacheFlutterVersion] is set as the global Flutter SDK version.
  ///
  /// [version] - The Flutter SDK version to check.
  /// Returns true if it is the global version, false otherwise.
  bool isGlobal(CacheFlutterVersion version) {
    if (!_globalCacheLink.existsSync()) return false;
    return _globalCacheLink.targetSync() == version.directory;
  }

  /// Retrieves the name of the global Flutter SDK version, if set.
  /// Returns null if no global version is configured.
  /// Provides only the version name, not the full SDK version object.
  String? getGlobalVersion() {
    if (!_globalCacheLink.existsSync()) return null;
    // Get directory name
    return path.basename(_globalCacheLink.targetSync());
  }
}

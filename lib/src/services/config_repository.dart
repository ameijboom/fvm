import 'dart:io';

import 'package:fvm/constants.dart';
import 'package:fvm/src/utils/helpers.dart';

import '../../fvm.dart';

/// Manages the configuration settings of FVM.
///
/// This class provides functionalities to load, save, and update the FVM configuration,
/// both from a file and environment variables. It ensures that the configuration settings
/// for FVM are centralized and managed consistently.
class ConfigRepository {
  // Private constructor to prevent direct instantiation.
  ConfigRepository._();

  /// Gets the path of the FVM configuration file.
  ///
  /// This is a private static getter that retrieves the path where the FVM configuration
  /// file is located. The path is defined in the FVM constants.
  static String get _configPath => kAppConfigFile;

  /// Loads the FVM configuration from a file.
  ///
  /// This method attempts to load the FVM configuration from the path specified by `_configPath`.
  /// If a configuration file exists, it returns the loaded configuration. Otherwise, it returns
  /// an empty configuration.
  ///
  /// Returns:
  ///   - [AppConfig]: The loaded or empty configuration.
  static AppConfig loadFile() {
    final appConfig = AppConfig.loadFromPath(_configPath);
    if (appConfig != null) return appConfig;
    return AppConfig.empty();
  }

  /// Saves the given FVM configuration to a file.
  ///
  /// This method saves the provided [config] object to the file located at `_configPath`.
  /// It overwrites any existing configuration file with the new settings.
  ///
  /// Parameters:
  ///   - [config] (AppConfig): The configuration object to save.
  static void save(AppConfig config) => config.save(_configPath);

  /// Updates the FVM configuration file with new settings.
  ///
  /// This method allows selectively updating various configuration options. It loads the
  /// current configuration, applies any provided updates, and then saves the new configuration.
  ///
  /// Parameters:
  ///   - [cachePath] (String?): The new cache path.
  ///   - [gitCache] (bool?): Whether to use the Git cache.
  ///   - [gitCachePath] (String?): The new Git cache path.
  ///   - [flutterUrl] (String?): The new Flutter URL.
  ///   - [disableUpdateCheck] (bool?): Whether to disable update checks.
  ///   - [lastUpdateCheck] (DateTime?): The timestamp of the last update check.
  static void update({
    String? cachePath,
    bool? gitCache,
    String? gitCachePath,
    String? flutterUrl,
    bool? disableUpdateCheck,
    DateTime? lastUpdateCheck,
  }) {
    final currentConfig = loadFile();
    final newConfig = currentConfig.copyWith(
      cachePath: cachePath,
      gitCache: gitCache,
      gitCachePath: gitCachePath,
      flutterUrl: flutterUrl,
      disableUpdateCheck: disableUpdateCheck,
      lastUpdateCheck: lastUpdateCheck,
    );
    save(newConfig);
  }

  /// Loads the FVM configuration from environment variables.
  ///
  /// This method iterates through known FVM configuration keys and checks if they are set
  /// in the environment. It builds a configuration object based on the environment variables.
  /// Special handling is provided for legacy variables and boolean values.
  ///
  /// Returns:
  ///   - [Config]: The configuration object populated with environment variable values.
  static EnvConfig loadEnv() {
    final environments = Platform.environment;

    bool? gitCache;
    String? gitCachePath;
    String? flutterUrl;
    String? cachePath;
    bool? priviledgedAccess;

    for (final variable in ConfigKeys.values) {
      final value = environments[variable.envKey];
      final legacyFvmHome = environments['FVM_HOME'];

      if (variable == ConfigKeys.cachePath) {
        cachePath = value ?? legacyFvmHome;
        break;
      }

      if (value == null) continue;

      if (variable == ConfigKeys.gitCache) {
        gitCache = stringToBool(value);
        break;
      }

      if (variable == ConfigKeys.gitCachePath) {
        gitCachePath = value;
        break;
      }

      if (variable == ConfigKeys.flutterUrl) {
        flutterUrl = value;
        break;
      }

      if (variable == ConfigKeys.priviledgedAccess) {
        priviledgedAccess = stringToBool(value);
        break;
      }
    }

    return EnvConfig(
      cachePath: cachePath,
      gitCache: gitCache,
      gitCachePath: gitCachePath,
      flutterUrl: flutterUrl,
      priviledgedAccess: priviledgedAccess,
    );
  }
}

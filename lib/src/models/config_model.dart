// Use just for reference, should not change

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:fvm/constants.dart';
import 'package:fvm/src/utils/change_case.dart';
import 'package:fvm/src/utils/extensions.dart';
import 'package:fvm/src/utils/pretty_json.dart';

/// Represents the keys used in FVM configurations.
/// Each key can be transformed into different string formats for various purposes.
class ConfigKeys {
  final String key;
  // Predefined constant keys used in FVM configurations.
  static ConfigKeys cachePath = ConfigKeys('cache_path');
  static ConfigKeys gitCache = ConfigKeys('git_cache');
  static ConfigKeys gitCachePath = ConfigKeys('git_cache_path');
  static ConfigKeys flutterUrl = ConfigKeys('flutter_url');
  static ConfigKeys priviledgedAccess = ConfigKeys('priviledged_access');

  // A static list containing all predefined ConfigKeys.
  static final values = <ConfigKeys>[
    cachePath,
    gitCache,
    gitCachePath,
    flutterUrl,
    priviledgedAccess,
  ];

  // Private method to access different case formats of the key using ChangeCase.
  final ChangeCase _recase;

  ConfigKeys(this.key) : _recase = ChangeCase(key);

  // Static method to retrieve a ConfigKey instance based on its string representation.
  static ConfigKeys fromName(String name) {
    return values.firstWhere((e) => e.key == name);
  }

  // Converts command-line arguments (ArgResults) to a Map, mapping configuration keys to their values.
  static argResultsToMap(ArgResults argResults) {
    final configMap = <String, dynamic>{};

    for (final key in values) {
      final value = argResults[key.paramKey];
      if (value != null) {
        configMap[key.propKey] = value;
      }
    }

    return configMap;
  }

  // Configures an ArgParser with options and flags based on the configuration keys.
  static injectArgParser(ArgParser argParser) {
    final configKeysFuncs = {
      ConfigKeys.cachePath.key: () {
        argParser.addOption(
          ConfigKeys.cachePath.paramKey,
          help: 'Path where $kPackageName will cache versions',
        );
      },
      ConfigKeys.gitCache.key: () {
        argParser.addFlag(
          ConfigKeys.gitCache.paramKey,
          help:
              'Enable/Disable git cache globally, which is used for faster version installs.',
          negatable: true,
          defaultsTo: true,
        );
      },
      ConfigKeys.gitCachePath.key: () {
        argParser.addOption(
          ConfigKeys.gitCachePath.paramKey,
          help: 'Path where local Git reference cache is stored',
        );
      },
      ConfigKeys.flutterUrl.key: () {
        argParser.addOption(
          ConfigKeys.flutterUrl.paramKey,
          help: 'Flutter repository Git URL to clone from',
        );
      },
      ConfigKeys.priviledgedAccess.key: () {
        argParser.addFlag(
          ConfigKeys.priviledgedAccess.paramKey,
          help: 'Enable/Disable priviledged access for FVM',
          negatable: true,
          defaultsTo: true,
        );
      },
    };

    for (final key in values) {
      configKeysFuncs[key.key]?.call();
    }
  }

  // Methods to get the key in different string formats: environment variable, parameter, and property key.
  String get envKey => 'FVM_${_recase.constantCase}';
  String get paramKey => _recase.paramCase;
  String get propKey => _recase.camelCase;

  @override
  operator ==(other) => other is ConfigKeys && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// Base configuration class for FVM settings.
abstract class Config {
  // If should use gitCache
  bool? gitCache;

  String? gitCachePath;

  /// Flutter repo url
  String? flutterUrl;

  /// Directory where FVM is stored
  String? cachePath;

  /// If FVM should run with priviledged access
  bool? priviledgedAccess;

  /// Constructor
  Config({
    required this.cachePath,
    required this.gitCache,
    required this.gitCachePath,
    required this.flutterUrl,
    required this.priviledgedAccess,
  });

  Map<String, dynamic> toMap() {
    return {
      if (cachePath != null) ConfigKeys.cachePath.propKey: cachePath,
      if (gitCache != null) ConfigKeys.gitCache.propKey: gitCache,
      if (gitCachePath != null) ConfigKeys.gitCachePath.propKey: gitCachePath,
      if (flutterUrl != null) ConfigKeys.flutterUrl.propKey: flutterUrl,
      if (priviledgedAccess != null)
        ConfigKeys.priviledgedAccess.propKey: priviledgedAccess,
    };
  }
}

class EnvConfig extends Config {
  EnvConfig({
    required super.cachePath,
    required super.gitCache,
    required super.gitCachePath,
    required super.flutterUrl,
    required super.priviledgedAccess,
  });

  factory EnvConfig.fromMap(Map<String, dynamic> map) {
    return EnvConfig(
      cachePath: map[ConfigKeys.cachePath.propKey] as String?,
      gitCache: map[ConfigKeys.gitCache.propKey] as bool?,
      gitCachePath: map[ConfigKeys.gitCachePath.propKey] as String?,
      flutterUrl: map[ConfigKeys.flutterUrl.propKey] as String?,
      priviledgedAccess: map[ConfigKeys.priviledgedAccess.propKey] as bool?,
    );
  }
}

/// Extended configuration class for application-specific settings, inheriting from Config.
class AppConfig extends Config {
  bool? disableUpdateCheck; // Indicates if update notifications are disabled.
  DateTime? lastUpdateCheck; // Timestamp of the last update check.

  // Constructor for initializing AppConfig with additional properties along with inherited ones.
  AppConfig({
    required this.disableUpdateCheck,
    required this.lastUpdateCheck,
    required super.cachePath,
    required super.gitCache,
    required super.gitCachePath,
    required super.flutterUrl,
    required super.priviledgedAccess,
  });

  // Factory constructor for creating an empty AppConfig instance.
  factory AppConfig.empty() {
    return AppConfig(
      disableUpdateCheck: null,
      lastUpdateCheck: null,
      cachePath: null,
      gitCache: null,
      gitCachePath: null,
      flutterUrl: null,
      priviledgedAccess: null,
    );
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      cachePath: map[ConfigKeys.cachePath.propKey] as String?,
      gitCache: map[ConfigKeys.gitCache.propKey] as bool?,
      gitCachePath: map[ConfigKeys.gitCachePath.propKey] as String?,
      flutterUrl: map[ConfigKeys.flutterUrl.propKey] as String?,
      priviledgedAccess: map[ConfigKeys.priviledgedAccess.propKey] as bool?,
      disableUpdateCheck: map['disableUpdateCheck'] as bool?,
      lastUpdateCheck: map['lastUpdateCheck'] != null
          ? DateTime.parse(map['lastUpdateCheck'] as String)
          : null,
    );
  }

  factory AppConfig.fromJson(String source) {
    return AppConfig.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  static AppConfig? loadFromPath(String path) {
    final configFile = File(path);

    return configFile.existsSync()
        ? AppConfig.fromJson(configFile.readAsStringSync())
        : null;
  }

  // Creates a copy of the current AppConfig instance with optional new values.
  AppConfig copyWith({
    String? cachePath,
    bool? gitCache,
    String? gitCachePath,
    String? flutterUrl,
    bool? disableUpdateCheck,
    DateTime? lastUpdateCheck,
    bool? priviledgedAccess,
  }) {
    return AppConfig(
      cachePath: cachePath ?? this.cachePath,
      gitCache: gitCache ?? this.gitCache,
      gitCachePath: gitCachePath ?? this.gitCachePath,
      flutterUrl: flutterUrl ?? this.flutterUrl,
      disableUpdateCheck: disableUpdateCheck ?? this.disableUpdateCheck,
      priviledgedAccess: priviledgedAccess ?? this.priviledgedAccess,
      lastUpdateCheck: lastUpdateCheck ?? this.lastUpdateCheck,
    );
  }

  // Merges the current AppConfig instance with another AppConfig instance.
  AppConfig merge(AppConfig? config) {
    return copyWith(
      cachePath: config?.cachePath,
      gitCache: config?.gitCache,
      gitCachePath: config?.gitCachePath,
      flutterUrl: config?.flutterUrl,
      disableUpdateCheck: config?.disableUpdateCheck,
      priviledgedAccess: config?.priviledgedAccess,
      lastUpdateCheck: config?.lastUpdateCheck,
    );
  }

  AppConfig mergeConfig(Config? config) {
    if (config == null) return this;

    return copyWith(
      cachePath: config.cachePath,
      gitCache: config.gitCache,
      gitCachePath: config.gitCachePath,
      flutterUrl: config.flutterUrl,
      priviledgedAccess: config.priviledgedAccess,
    );
  }

  void save(String path) {
    final jsonContents = prettyJson(toMap());

    path.file.write(jsonContents);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      if (disableUpdateCheck != null) 'disableUpdateCheck': disableUpdateCheck,
      if (lastUpdateCheck != null)
        'lastUpdateCheck': lastUpdateCheck?.toIso8601String(),
    };
  }
}

/// Project config
class ProjectConfig extends Config {
  /// Flutter SDK version configured
  String? flutterSdkVersion;

  /// Flavors configured
  Map<String, String>? flavors;

  /// If Vscode settings is not managed by FVM
  bool? _updateVscodeSettings;

  /// If FVM should update .gitignore
  bool? _updateGitIgnore;

  /// If should run pub get on sdk change
  bool? _runPubGetOnSdkChanges;

  /// Constructor
  ProjectConfig({
    super.cachePath,
    super.gitCache,
    super.gitCachePath,
    super.flutterUrl,
    super.priviledgedAccess,
    this.flutterSdkVersion,
    this.flavors,
    bool? updateVscodeSettings,
    bool? updateGitIgnore,
    bool? runPubGetOnSdkChanges,
  })  : _updateVscodeSettings = updateVscodeSettings,
        _updateGitIgnore = updateGitIgnore,
        _runPubGetOnSdkChanges = runPubGetOnSdkChanges;

  /// Returns ConfigDto from a map
  factory ProjectConfig.fromMap(Map<String, dynamic> map) {
    return ProjectConfig(
      cachePath: map[ConfigKeys.cachePath.propKey] as String?,
      gitCache: map[ConfigKeys.gitCache.propKey] as bool?,
      gitCachePath: map[ConfigKeys.gitCachePath.propKey] as String?,
      flutterUrl: map[ConfigKeys.flutterUrl.propKey] as String?,
      priviledgedAccess: map[ConfigKeys.priviledgedAccess.propKey] as bool?,
      updateGitIgnore: map['updateGitIgnore'] as bool?,
      flutterSdkVersion: map['flutterSdkVersion'] ?? map['flutter'] as String?,
      updateVscodeSettings: map['updateVscodeSettings'] as bool?,
      runPubGetOnSdkChanges: map['runPubGetOnSdkChanges'] as bool?,
      flavors: map['flavors'] != null ? Map.from(map['flavors'] as Map) : null,
    );
  }

  /// Returns ConfigDto from a json string
  factory ProjectConfig.fromJson(String source) =>
      ProjectConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  static ProjectConfig? loadFromPath(String path) {
    final configFile = File(path);

    return configFile.existsSync()
        ? ProjectConfig.fromJson(configFile.readAsStringSync())
        : null;
  }

  /// Returns update vscode settings
  bool? get updateVscodeSettings => _updateVscodeSettings;

  /// Returns update git ignore
  bool? get updateGitIgnore => _updateGitIgnore;

  /// Returns run pub get on sdk changes
  bool? get runPubGetOnSdkChanges => _runPubGetOnSdkChanges;

  /// Copies current config and overrides with new values
  /// Returns a new ProjectConfig

  ProjectConfig copyWith({
    String? cachePath,
    String? flutterSdkVersion,
    bool? gitCache,
    bool? updateVscodeSettings,
    bool? updateGitIgnore,
    bool? runPubGetOnSdkChanges,
    bool? priviledgedAccess,
    String? gitCachePath,
    String? flutterUrl,
    Map<String, String>? flavors,
  }) {
    // merge map and override the keys
    final mergedFlavors = <String, String>{
      if (this.flavors != null) ...this.flavors!,
      if (flavors != null) ...flavors,
    };

    return ProjectConfig(
      cachePath: cachePath ?? cachePath,
      flutterSdkVersion: flutterSdkVersion ?? this.flutterSdkVersion,
      flavors: mergedFlavors,
      priviledgedAccess: priviledgedAccess ?? this.priviledgedAccess,
      updateVscodeSettings: updateVscodeSettings ?? _updateVscodeSettings,
      runPubGetOnSdkChanges: runPubGetOnSdkChanges ?? _runPubGetOnSdkChanges,
      updateGitIgnore: updateGitIgnore ?? _updateGitIgnore,
      gitCache: gitCache ?? this.gitCache,
      gitCachePath: gitCachePath ?? this.gitCachePath,
      flutterUrl: flutterUrl ?? this.flutterUrl,
    );
  }

  void save(String path) {
    final jsonContents = prettyJson(toMap());

    path.file.write(jsonContents);
  }

  /// It checks each property for null prior to adding it to the map.
  /// This is to ensure the returned map doesn't contain any null values.
  /// Also, if [flavors] is not empty it adds it to the map.

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      if (flutterSdkVersion != null) 'flutter': flutterSdkVersion,
      if (_updateVscodeSettings != null)
        'updateVscodeSettings': _updateVscodeSettings,
      if (_updateGitIgnore != null) 'updateGitIgnore': _updateGitIgnore,
      if (_runPubGetOnSdkChanges != null)
        'runPubGetOnSdkChanges': _runPubGetOnSdkChanges,
      if (flavors != null && flavors!.isNotEmpty) 'flavors': flavors,
    };
  }
}

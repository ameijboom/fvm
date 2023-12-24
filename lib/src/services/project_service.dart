import 'dart:io';

import 'package:fvm/src/models/config_model.dart';
import 'package:fvm/src/models/project_model.dart';
import 'package:fvm/src/services/base_service.dart';
import 'package:fvm/src/utils/context.dart';
import 'package:fvm/src/utils/extensions.dart';
import 'package:fvm/src/utils/pretty_json.dart';
import 'package:path/path.dart' as path;

/// Provides services for interacting with local Flutter projects.
/// This includes functionalities like finding and updating project configurations.
class ProjectService extends ContextService {
  const

  /// Constructs the ProjectService with the given context.
  ProjectService(super.context);

  /// Retrieves an instance of ProjectService from the provided context.
  static ProjectService get fromContext => getProvider();

  /// Recursively searches for a Flutter project directory starting from [directory].
  /// If [directory] is null, the search begins from the current working directory.
  ///
  /// [directory] - The directory to start the search from. Defaults to the current working directory if null.
  Project findAncestor({
    Directory? directory, // The directory to start the search from.
  }) {
    directory ??= Directory(context.workingDirectory);
    final isRootDir = path.rootPrefix(directory.path) == directory.path;
    final project = Project.loadFromPath(directory.path);

    if (project.hasConfig) return project;
    if (isRootDir) return Project.loadFromPath(context.workingDirectory);
    return findAncestor(directory: directory.parent);
  }

  /// Searches for the Flutter SDK version configured for the current project.
  /// Returns the version name or `null` if no version is pinned.
  String? findVersion() {
    final project = findAncestor();
    return project.pinnedVersion?.name;
  }

  /// Updates the project with new configurations.
  ///
  /// - [project] - The project to update.
  /// - [flavors] - A map of flavor configurations to apply to the project. Defaults to an empty map.
  /// - [flutterSdkVersion] - The Flutter SDK version to pin to this project. If null, the version won't be changed.
  /// - [updateVscodeSettings] - A flag to determine whether to update VS Code settings. If null, the setting remains unchanged.
  Project update(
    Project project, {
    Map<String, String> flavors = const {}, // Additional flavor configurations.
    String? flutterSdkVersion, // Flutter SDK version to pin.
    bool? updateVscodeSettings, // Whether to update VS Code settings.
  }) {
    final newConfig = project.config ?? ProjectConfig();
    final config = newConfig.copyWith(
      flavors: flavors,
      flutterSdkVersion: flutterSdkVersion,
      updateVscodeSettings: updateVscodeSettings,
    );

    final configFile = project.configPath.file;
    if (!configFile.existsSync()) {
      configFile.createSync(recursive: true);
    }

    final jsonContents = prettyJson(config.toMap());
    configFile.write(jsonContents);
    return Project.loadFromPath(project.path);
  }
}

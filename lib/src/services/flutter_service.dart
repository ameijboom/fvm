import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fvm/src/services/base_service.dart';
import 'package:fvm/src/services/logger_service.dart';
import 'package:fvm/src/services/releases_service/releases_client.dart';
import 'package:fvm/src/utils/context.dart';
import 'package:fvm/src/utils/parsers/git_clone_update_printer.dart';
import 'package:git/git.dart';
import 'package:mason_logger/mason_logger.dart';

import '../../exceptions.dart';
import '../../fvm.dart';
import '../models/flutter_version_model.dart';
import '../utils/commands.dart';

/// Provides functionality to interact with and manage the Flutter SDK.
/// This class includes methods for upgrading, installing, and verifying Flutter SDK versions.
class FlutterService extends ContextService {
  FlutterService(super.context);

  /// Retrieves an instance of [FlutterService] from the current context.
  static FlutterService get fromContext => getProvider<FlutterService>();

  /// Upgrades a cached Flutter SDK channel to the latest version.
  /// Throws [AppException] if the provided version is not a channel.
  ///
  /// [version] - The channel version of the Flutter SDK to upgrade.
  Future<void> runUpgrade(CacheFlutterVersion version) async {
    if (version.isChannel) {
      await runFlutter(['upgrade'], version: version);
    } else {
      throw AppException('Can only upgrade Flutter Channels');
    }
  }

  /// Installs the Flutter SDK from a specified [FlutterVersion].
  /// The method handles both channel and specific version installations.
  ///
  /// [version] - The version of the Flutter SDK to install.
  Future<void> install(FlutterVersion version) async {
    final versionDir = CacheService(context).getVersionCacheDir(version.name);

    // Check if its git commit
    String? channel;

    if (version.isChannel) {
      channel = version.name;
      // If its not a commit hash
    } else if (version.isRelease) {
      if (version.releaseFromChannel != null) {
        // Version name forces channel version
        channel = version.releaseFromChannel;
      } else {
        final release =
            await FlutterReleases.getReleaseFromVersion(version.name);
        channel = release?.channel.name;
      }
    }

    final versionCloneParams = [
      '-c',
      'advice.detachedHead=false',
      '-b',
      channel ?? version.name,
    ];

    final useMirrorParams = [
      '--reference',
      context.gitCachePath,
    ];

    final cloneArgs = [
      //if its a git hash
      if (!version.isCommit) ...versionCloneParams,
      if (context.gitCache) ...useMirrorParams,
    ];

    try {
      final result = await runGit(
        [
          'clone',
          '--progress',
          ...cloneArgs,
          context.flutterUrl,
          versionDir.path,
        ],
        echoOutput: context.isTest || !logger.isVerbose ? false : true,
      );

      final gitVersionDir =
          CacheService(context).getVersionCacheDir(version.name);
      final isGit = await GitDir.isGitDir(gitVersionDir.path);

      if (!isGit) {
        throw AppException(
          'Flutter SDK is not a valid git repository after clone. Please try again.',
        );
      }

      /// If version is not a channel reset to version
      if (!version.isChannel) {
        final gitDir = await GitDir.fromExisting(gitVersionDir.path);
        // reset --hard $version
        await gitDir.runCommand(['reset', '--hard', version.version]);
      }

      if (result.exitCode != ExitCode.success.code) {
        throw AppException(
          'Could not clone Flutter SDK: ${cyan.wrap(version.printFriendlyName)}',
        );
      }
    } on Exception {
      CacheService(context).remove(version);
      rethrow;
    }

    return;
  }

  /// Updates the local Flutter repository mirror.
  /// This method is primarily used for testing purposes.
  Future<void> updateLocalMirror() async {
    final isGitDir = await GitDir.isGitDir(context.gitCachePath);

    // If cache file does not exists create it
    if (isGitDir) {
      final gitDir = await GitDir.fromExisting(context.gitCachePath);
      logger.detail('Syncing local mirror...');

      try {
        await gitDir.runCommand(['pull', 'origin']);
      } on ProcessException catch (e) {
        logger.err(e.message);
      }
    } else {
      final gitCacheDir = Directory(context.gitCachePath);
      // Ensure brand new directory
      if (gitCacheDir.existsSync()) {
        gitCacheDir.deleteSync(recursive: true);
      }
      gitCacheDir.createSync(recursive: true);

      logger.info('Creating local mirror...');

      await runGitCloneUpdate(
        ['clone', '--progress', context.flutterUrl, gitCacheDir.path],
      );
    }
  }

  /// Ensures that the git cache directory exists and is up-to-date.
  Future<void> _ensureCacheDir() async {
    final isGitDir = await GitDir.isGitDir(context.gitCachePath);

    // If cache file does not exists create it
    if (!isGitDir) {
      await updateLocalMirror();
    }
  }

  /// Checks if a given commit exists in the Flutter repository.
  /// Returns true if the commit exists, otherwise false.
  ///
  /// [commit] - The commit SHA or hash to check.
  Future<bool> isCommit(String commit) async {
    final commitSha = await getReference(commit);
    if (commitSha == null) {
      return false;
    }
    return commit.contains(commitSha);
  }

  /// Checks if a given tag exists in the Flutter repository.
  /// Returns true if the tag exists, otherwise false.
  ///
  /// [tag] - The tag to check.
  Future<bool> isTag(String tag) async {
    final commitSha = await getReference(tag);
    if (commitSha == null) {
      return false;
    }

    final tags = await getTags();
    return tags.where((t) => t == tag).isNotEmpty;
  }

  /// Retrieves a list of all tags from the local Flutter repository mirror.
  /// Returns an empty list if no tags are found or on failure.
  Future<List<String>> getTags() async {
    await _ensureCacheDir();
    final isGitDir = await GitDir.isGitDir(context.gitCachePath);
    if (!isGitDir) {
      throw Exception('Git cache directory does not exist');
    }

    final gitDir = await GitDir.fromExisting(context.gitCachePath);
    final result = await gitDir.runCommand(['tag']);
    if (result.exitCode != 0) {
      return [];
    }

    return LineSplitter.split(result.stdout as String)
        .map((line) => line.trim())
        .toList();
  }

  /// Gets a reference (commit SHA) for a given ref in the Flutter repository.
  /// Returns null if the ref does not exist.
  ///
  /// [ref] - The reference to verify (can be a branch, tag, or commit SHA).
  Future<String?> getReference(String ref) async {
    await _ensureCacheDir();
    final isGitDir = await GitDir.isGitDir(context.gitCachePath);
    if (!isGitDir) {
      throw Exception('Git cache directory does not exist');
    }

    final gitDir = await GitDir.fromExisting(context.gitCachePath);
    try {
      final result = await gitDir.runCommand(
        ['rev-parse', '--short', '--verify', ref],
      );

      return result.stdout.trim();
    } on Exception {
      return null;
    }
  }
}

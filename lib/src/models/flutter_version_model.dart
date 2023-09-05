import 'package:fvm/src/utils/compare_semver.dart';
import 'package:fvm/src/utils/is_git_commit.dart';

import '../../constants.dart';
import '../utils/helpers.dart';

/// Provides a structured way to handle Flutter SDK versions.
///
/// This class allows for specific use-cases and categorizations of Flutter SDK
/// versions such as distinguishing if a version is a release, a channel, a git
/// commit or a custom version. Moreover, it allows for fetching a print-friendly
/// name to be used in user interfaces.
class FlutterVersion {
  /// Represents the underlying string value of the Flutter version.
  final String name;

  /// Has a cannel which the version is part of
  final String? releaseChannel;

  /// Identifies if the version is an official Flutter SDK release.
  final bool isRelease;

  /// Identifies if the version represents a specific git commit.
  final bool isCommit;

  /// Identifies if the version belongs to a Flutter channel.
  final bool isChannel;

  /// Identifies if the version represents a custom Flutter SDK version.
  final bool isCustom;

  /// Identifies if the version belongs to the Flutter master channel.
  final bool isMaster;

  /// Constructs a [FlutterVersion] instance initialized with a given [name].
  const FlutterVersion(
    this.name, {
    this.releaseChannel,
    required this.isRelease,
    required this.isCommit,
    required this.isChannel,
    required this.isCustom,
    required this.isMaster,
  });

  factory FlutterVersion.fromString(String version) {
    final parts = version.split('@');

    String? releaseChannel;

    if (parts.length > 1 && kFlutterChannels.contains(parts.last)) {
      releaseChannel = parts.last;
    }

    final isCommit = isGitCommit(version);
    final isChannel = kFlutterChannels.contains(version);
    final isRelease = !isCommit && !isChannel;

    final isCustom = version.startsWith('custom_');

    final isMaster = version == 'master';

    return FlutterVersion(
      version.trim(),
      releaseChannel: releaseChannel,
      isRelease: isRelease,
      isCommit: isCommit,
      isChannel: isChannel,
      isCustom: isCustom,
      isMaster: isMaster,
    );
  }

  String get version {
    return name.split('@').first;
  }

  /// Provides a human readable version identifier for UI presentation.
  ///
  /// The return value varies based on the type of version:
  /// * 'Channel: [name]' for channel versions.
  /// * 'Commit: [name]' for commit versions.
  /// * 'SDK Version: [name]' for standard versions.
  String get printFriendlyName {
    if (isChannel) return 'Channel: $name';

    if (isCommit) return 'Commit: $name';

    return 'SDK Version: $name';
  }

  /// Compares CacheVersion with [other]
  int compareTo(FlutterVersion other) {
    final otherVersion = assignVersionWeight(other.version);
    final versionWeight = assignVersionWeight(version);
    return compareSemver(versionWeight, otherVersion);
  }

  /// Overrides toString method for better debugging and logging.
  ///
  /// Instead of the instance identifier, the version [name] is returned.
  @override
  String toString() => name;
}

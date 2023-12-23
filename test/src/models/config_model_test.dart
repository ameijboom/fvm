import 'package:fvm/src/models/config_model.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigKeys', () {
    test('envKey', () {
      expect(ConfigKeys.cachePath.envKey, 'FVM_CACHE_PATH');
      expect(ConfigKeys.gitCache.envKey, 'FVM_GIT_CACHE');
      expect(ConfigKeys.gitCachePath.envKey, 'FVM_GIT_CACHE_PATH');
      expect(ConfigKeys.flutterUrl.envKey, 'FVM_FLUTTER_URL');
      expect(ConfigKeys.priviledgedAccess.envKey, 'FVM_PRIVILEDGED_ACCESS');
    });

    test('paramKey', () {
      expect(ConfigKeys.cachePath.paramKey, 'cache-path');
      expect(ConfigKeys.gitCache.paramKey, 'git-cache');
      expect(ConfigKeys.gitCachePath.paramKey, 'git-cache-path');
      expect(ConfigKeys.flutterUrl.paramKey, 'flutter-url');
      expect(ConfigKeys.priviledgedAccess.paramKey, 'priviledged-access');
    });

    test('propKey', () {
      expect(ConfigKeys.cachePath.propKey, 'cachePath');
      expect(ConfigKeys.gitCache.propKey, 'gitCache');
      expect(ConfigKeys.gitCachePath.propKey, 'gitCachePath');
      expect(ConfigKeys.flutterUrl.propKey, 'flutterUrl');
      expect(ConfigKeys.priviledgedAccess.propKey, 'priviledgedAccess');
    });

    test('fromName', () {
      expect(ConfigKeys.fromName('cache_path'), ConfigKeys.cachePath);
      expect(ConfigKeys.fromName('git_cache'), ConfigKeys.gitCache);
      expect(ConfigKeys.fromName('git_cache_path'), ConfigKeys.gitCachePath);
      expect(ConfigKeys.fromName('flutter_url'), ConfigKeys.flutterUrl);
      expect(ConfigKeys.fromName('priviledged_access'),
          ConfigKeys.priviledgedAccess);
    });
  });

  group('AppConfig', () {
    test('copyWith', () {
      final config = AppConfig(
        cachePath: '/path/to/cache',
        gitCache: true,
        gitCachePath: '/path/to/git/cache',
        flutterUrl: 'https://github.com/flutter/flutter.git',
        priviledgedAccess: false,
        disableUpdateCheck: true,
        lastUpdateCheck: DateTime(2022, 1, 1),
      );

      final updatedConfig = config.copyWith(cachePath: '/new/path/to/cache');

      expect(updatedConfig.cachePath, '/new/path/to/cache');
      expect(updatedConfig.gitCache, true);
      expect(updatedConfig.gitCachePath, '/path/to/git/cache');
      expect(
          updatedConfig.flutterUrl, 'https://github.com/flutter/flutter.git');
      expect(updatedConfig.priviledgedAccess, false);
      expect(updatedConfig.disableUpdateCheck, true);
      expect(updatedConfig.lastUpdateCheck, DateTime(2022, 1, 1));
    });

    test('merge', () {
      final config1 = AppConfig(
        cachePath: '/path/to/cache',
        gitCache: true,
        gitCachePath: '/path/to/git/cache',
        flutterUrl: 'https://github.com/flutter/flutter.git',
        priviledgedAccess: false,
        disableUpdateCheck: true,
        lastUpdateCheck: DateTime(2022, 1, 1),
      );

      final config2 = AppConfig(
        cachePath: '/new/path/to/cache',
        gitCache: false,
        gitCachePath: '/new/path/to/git/cache',
        flutterUrl: 'https://github.com/flutter/flutter.git',
        priviledgedAccess: true,
        disableUpdateCheck: false,
        lastUpdateCheck: DateTime(2023, 1, 1),
      );

      final mergedConfig = config1.merge(config2);

      expect(mergedConfig.cachePath, '/new/path/to/cache');
      expect(mergedConfig.gitCache, false);
      expect(mergedConfig.gitCachePath, '/new/path/to/git/cache');
      expect(mergedConfig.flutterUrl, 'https://github.com/flutter/flutter.git');
      expect(mergedConfig.priviledgedAccess, true);
      expect(mergedConfig.disableUpdateCheck, false);
      expect(mergedConfig.lastUpdateCheck, DateTime(2023, 1, 1));
    });
  });
}


Beginning of file: lib/fvm.dart


Beginning of file: lib/exceptions.dart

class AppException
- String message
- String toString()
class AppDetailedException extends AppException
- String info
- String toString()

Beginning of file: lib/constants.dart


Beginning of file: lib/src/runner.dart

class FvmCommandRunner extends CommandRunner
- PubUpdater _pubUpdater
- void printUsage()
- Future<int> run(Iterable<String> args)
- Future<int?> runCommand(ArgResults topLevelResults)
- Future< Function()?> _checkForUpdates()

Beginning of file: lib/src/workflows/use_version.workflow.dart


Beginning of file: lib/src/workflows/ensure_cache.workflow.dart


Beginning of file: lib/src/workflows/resolve_dependencies.workflow.dart


Beginning of file: lib/src/workflows/setup_flutter.workflow.dart


Beginning of file: lib/src/utils/helpers.dart

class FlutterVersionOutput
- String? flutterVersion
- String? channel
- String? dartVersion
- String? dartBuildVersion
- String toString()

Beginning of file: lib/src/utils/cli_util.dart


Beginning of file: lib/src/utils/parsers/git_clone_update_printer.dart


Beginning of file: lib/src/utils/console_utils.dart


Beginning of file: lib/src/utils/extensions.dart

- T? firstWhereOrNull(bool Function(T) test)
- get Directory dir
- get File file
- get Link link
- bool exists()
- FileSystemEntityType type()
- bool isDir()
- bool isFile()
- String? read()
- void write(String contents)
- void deleteIfExists()
- void ensureExists()
- void createLink(String targetPath)
- get String capitalize

Beginning of file: lib/src/utils/run_command.dart


Beginning of file: lib/src/utils/context.dart

class FVMContext
- FVMContext main
- String id
- String workingDirectory
- bool isTest
- AppConfig config
- Map<Type, dynamic>? generators
- Map<Type, dynamic> _dependencies
- get Map<String, String> environment
- get String fvmDir
- get bool gitCache
- get String gitCachePath
- get String flutterUrl
- get DateTime? lastUpdateCheck
- get bool updateCheckDisabled
- get bool priviledgedAccess
- get String globalCacheLink
- get String globalCacheBinPath
- get String versionsCachePath
- get String configPath
- T get()
- String toString()

Beginning of file: lib/src/utils/which.dart


Beginning of file: lib/src/utils/pretty_json.dart


Beginning of file: lib/src/utils/compare_semver.dart


Beginning of file: lib/src/utils/deprecation_util.dart


Beginning of file: lib/src/utils/commands.dart


Beginning of file: lib/src/utils/http.dart


Beginning of file: lib/src/utils/git_utils.dart


Beginning of file: lib/src/utils/change_case.dart

class ChangeCase
- String text
- get List<String> _words
- List<String> _groupWords(String text)
- get String camelCase
- get String constantCase
- get String snakeCase
- get String paramCase
- String _getCamelCase()
- String _uppercase(String separator)
- String _lowerCase(String separator)
- String _upperCaseFirstLetter(String word)
- get String capitalize
- get List<String> lowercase
- get List<String> uppercase

Beginning of file: lib/src/models/flutter_version_model.dart

class FlutterVersion
- String name
- String? releaseFromChannel
- bool isRelease
- bool isCommit
- bool isChannel
- bool isCustom
- get String version
- get bool isMaster
- get String printFriendlyName
- int compareTo(FlutterVersion other)
- String toString()

Beginning of file: lib/src/models/config_model.dart

class ConfigKeys
- String key
- null ==()
- get int hashCode
- get ChangeCase _recase
- ConfigKeys cachePath
- ConfigKeys useGitCache
- ConfigKeys gitCachePath
- ConfigKeys flutterUrl
- ConfigKeys priviledgedAccess
- get String envKey
- get String paramKey
- get String propKey
- Unknown values
- ConfigKeys fromName(String name)
- null argResultsToMap(ArgResults argResults)
- null injectArgParser(ArgParser argParser)
class Config
- bool? useGitCache
- String? gitCachePath
- String? flutterUrl
- String? cachePath
- bool? priviledgedAccess
- Map<String, dynamic> toMap()
class AppConfig extends Config
- bool? disableUpdateCheck
- DateTime? lastUpdateCheck
- AppConfig? loadFromPath(String path)
- Map<String, dynamic> toMap()
- AppConfig copyWith()
- AppConfig merge(AppConfig? config)
- AppConfig mergeConfig(Config? config)
- void save(String path)
class ProjectConfig extends Config
- String? flutterSdkVersion
- Map<String, String>? flavors
- bool? _updateVscodeSettings
- bool? _updateGitIgnore
- bool? _runPubGetOnSdkChanges
- get bool? updateVscodeSettings
- get bool? updateGitIgnore
- get bool? runPubGetOnSdkChanges
- ProjectConfig? loadFromPath(String path)
- Map<String, dynamic> toMap()
- ProjectConfig copyWith()
- ProjectConfig merge(ProjectConfig config)
- void save(String path)

Beginning of file: lib/src/models/cache_flutter_version_model.dart

class CacheFlutterVersion extends FlutterVersion
- String directory
- get String binPath
- get bool hasOldBinPath
- get String _dartSdkCache
- get String dartBinPath
- get String dartExec
- get String flutterExec
- get String? flutterSdkVersion
- get String? dartSdkVersion
- get bool notSetup
- Future<ProcessResult> run(String command)
- String toString()
- bool ==(Object other)
- get int hashCode

Beginning of file: lib/src/models/project_model.dart

class Project
- String path
- ProjectConfig? config
- PubSpec? pubspec
- get String name
- get FlutterVersion? pinnedVersion
- get String? activeFlavor
- get Map<String, String> flavors
- get String? dartToolGeneratorVersion
- get String? dartToolVersion
- get bool isFlutter
- get String localFvmPath
- get String localVersionsCachePath
- get String localVersionSymlinkPath
- get File gitignoreFile
- get String pubspecPath
- get String configPath
- get bool hasConfig
- get bool hasPubspec
- get VersionConstraint? sdkConstraint
- Project loadFromPath(String path)

Beginning of file: lib/src/commands/exec_command.dart

class ExecCommand extends BaseCommand
- Unknown name
- Unknown description
- Unknown argParser
- Future<int> run()

Beginning of file: lib/src/commands/config_command.dart

class ConfigCommand extends BaseCommand
- Unknown name
- Unknown description
- Future<int> run()

Beginning of file: lib/src/commands/flutter_command.dart

class FlutterCommand extends BaseCommand
- Unknown name
- Unknown description
- Unknown argParser
- Future<int> run()

Beginning of file: lib/src/commands/global_command.dart

class GlobalCommand extends BaseCommand
- Unknown name
- Unknown description
- get String invocation
- Future<int> run()

Beginning of file: lib/src/commands/update_command.dart

class UpdateCommand extends Command
- PubUpdater _pubUpdater
- get String description
- String commandName
- get String name
- Future<int> run()

Beginning of file: lib/src/commands/list_command.dart

class ListCommand extends BaseCommand
- Unknown name
- Unknown description
- get List<String> aliases
- Future<int> run()

Beginning of file: lib/src/commands/install_command.dart

class InstallCommand extends BaseCommand
- Unknown name
- Unknown description
- get String invocation
- get List<String> aliases
- Future<int> run()

Beginning of file: lib/src/commands/base_command.dart

class BaseCommand extends Command
- get String invocation
- bool wasParsed(String name)
- bool boolArg(String name)
- String? stringArg(String name)
- List<String?> stringsArg(String name)

Beginning of file: lib/src/commands/commands.dart


Beginning of file: lib/src/commands/dart_command.dart

class DartCommand extends BaseCommand
- Unknown name
- Unknown description
- Unknown argParser
- Future<int> run()

Beginning of file: lib/src/commands/remove_command.dart

class RemoveCommand extends BaseCommand
- Unknown name
- Unknown description
- get String invocation
- Future<int> run()

Beginning of file: lib/src/commands/releases_command.dart

class ReleasesCommand extends BaseCommand
- Unknown name
- Unknown description
- Future<int> run()

Beginning of file: lib/src/commands/spawn_command.dart

class SpawnCommand extends BaseCommand
- Unknown name
- Unknown description
- Unknown argParser
- Future<int> run()

Beginning of file: lib/src/commands/doctor_command.dart

class DoctorCommand extends BaseCommand
- Unknown name
- Unknown description
- Unknown console
- Future<int> run()
- void printFVMDetails(FVMContext context)
- void _printProject(Project project)
- void _printIdeLinks(Project project)
- void _printEnvironmentDetails(String? flutterWhich, String? dartWhich)

Beginning of file: lib/src/commands/use_command.dart

class UseCommand extends BaseCommand
- Unknown name
- String description
- get String invocation
- Future<int> run()

Beginning of file: lib/src/services/config_repository.dart

class ConfigRepository
- get String _configPath
- AppConfig loadFile()
- void save(AppConfig config)
- void update()
- Config loadEnv()

Beginning of file: lib/src/services/releases_service/releases_client.dart

class FlutterReleases
- Releases? _cacheReleasesRes
- Future<Releases> get()
- Future<Releases> _getFromFlutterUrl(String platform)
- Future<Release> getLatestReleaseOfChannel(FlutterChannel channel)
- Future<Release?> getReleaseFromVersion(String version)

Beginning of file: lib/src/services/releases_service/models/channels.model.dart

- String name
- FlutterChannel fromName(String name)

Beginning of file: lib/src/services/releases_service/models/release.model.dart

class Release
- String hash
- FlutterChannel channel
- String version
- DateTime releaseDate
- String archive
- String sha256
- bool activeChannel
- String? dartSdkVersion
- String? dartSdkArch
- Map<String, dynamic> toMap()
- get String channelName
- get String archiveUrl
class Channels
- Release beta
- Release dev
- Release stable
- Release [](String channelName)
- Map<String, dynamic> toMap()
- Map<String, dynamic> toHashMap()
- get List<Release> toList

Beginning of file: lib/src/services/releases_service/models/flutter_releases.model.dart

class Releases
- String baseUrl
- Channels channels
- List<Release> releases
- Map<String, Release> versionReleaseMap
- Map<String, Release> hashReleaseMap
- Release getLatestChannelRelease(String channelName)
- Release? getReleaseFromVersion(String version)
- bool containsVersion(String version)
- Map<String, dynamic> toMap()

Beginning of file: lib/src/services/base_service.dart

class ContextService
- FVMContext? _context
- get FVMContext context

Beginning of file: lib/src/services/global_version_service.dart

class GlobalVersionService extends ContextService
- get GlobalVersionService fromContext
- void setGlobal(CacheFlutterVersion version)
- get Link _globalCacheLink
- CacheFlutterVersion? getGlobal()
- bool isGlobal(CacheFlutterVersion version)
- String? getGlobalVersion()

Beginning of file: lib/src/services/project_service.dart

class ProjectService extends ContextService
- get ProjectService fromContext
- Project findAncestor()
- String? findVersion()
- Project update(Project project)

Beginning of file: lib/src/services/flutter_service.dart

class FlutterService extends ContextService
- get FlutterService fromContext
- Future<void> runUpgrade(CacheFlutterVersion version)
- Future<void> install(FlutterVersion version)
- Future<void> updateLocalMirror()
- Future<void> _ensureCacheDir()
- Future<bool> isCommit(String commit)
- Future<bool> isTag(String tag)
- Future<List<String>> getTags()
- Future<String?> getReference(String ref)
class FlutterServiveMock extends FlutterService
- Future<void> install(FlutterVersion version)

Beginning of file: lib/src/services/cache_service.dart

class CacheService extends ContextService
- get CacheService fromContext
- CacheFlutterVersion? getVersion(FlutterVersion version)
- Future<List<CacheFlutterVersion>> getAllVersions()
- void remove(FlutterVersion version)
- Future<bool> _verifyIsExecutable(CacheFlutterVersion version)
- bool _verifyVersionMatch(CacheFlutterVersion version)
- Directory getVersionCacheDir(String version)
- Future<CacheIntegrity> verifyCacheIntegrity(CacheFlutterVersion version)
- void moveToSdkVersionDiretory(CacheFlutterVersion version)

Beginning of file: lib/src/services/logger_service.dart

class LoggerService extends ContextService
- Logger _logger
- get void spacer
- get bool isVerbose
- set null level(Level level)
- get Level level
- void success(String message)
- void fail(String message)
- void warn(String message)
- void info(String message)
- void err(String message)
- void detail(String message)
- void write(String message)
- Progress progress(String message)
- bool confirm(String? message)
- get String stdout
- String select(String? message)
- void notice(String message)
- void important(String message)
- get void divider
class ConsoleController
- Unknown stdout
- Unknown stderr
- Unknown warning
- Unknown fine
- Unknown info
- Unknown error
class Icons
- get String success
- get String failure
- get String info
- get String warning
- get String arrowRight
- get String arrowLeft
- get String checkBox
- get String star
- get String circle
- get String square

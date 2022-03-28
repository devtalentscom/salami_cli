import 'package:mason/mason.dart';
import 'package:salami_cli/src/cli/cli.dart';
import 'package:universal_io/io.dart';

/// Runs `flutter packages get` in the [outputDir].
Future<void> installFlutterPackages(
  Logger logger,
  Directory outputDir, {
  bool recursive = false,
}) async {
  final isFlutterInstalled = await Flutter.installed();
  if (isFlutterInstalled) {
    final installDependenciesDone = logger.progress(
      'Running "flutter packages get" in ${outputDir.path}',
    );
    await Flutter.packagesGet(cwd: outputDir.path, recursive: recursive);
    installDependenciesDone();
  }
}

/// Runs `dart fix --apply` in the [outputDir].
Future<void> applyDartFixes(
  Logger logger,
  Directory outputDir, {
  bool recursive = false,
}) async {
  final isDartInstalled = await Dart.installed();
  if (isDartInstalled) {
    final applyFixesDone = logger.progress(
      'Running "dart fix --apply" in ${outputDir.path}',
    );
    await Dart.applyFixes(cwd: outputDir.path, recursive: recursive);
    applyFixesDone();
  }
}

/// Runs `flutter packages get`.
Future<void> installMelos(
  Logger logger,
) async {
  final installMelosDone = logger.progress(
    'Checking if melos is activated',
  );
  final isMelosInstalled = await Melos.installed();
  if (!isMelosInstalled) {
    logger.progress(
      'Running "dart pub global activate melos"',
    );
    await Melos.activate();
    installMelosDone();
  } else {
    installMelosDone('Melos already activated');
  }
}

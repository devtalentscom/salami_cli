import 'package:mason/mason.dart';
import 'package:salami_cli/src/commands/create/templates/templates.dart';
import 'package:universal_io/io.dart';

/// {@template salami_core_template}
/// A core Flutter app template.
/// {@endtemplate}
class SalamiCoreTemplate extends Template {
  /// {@macro salami_core_template}
  SalamiCoreTemplate()
      : super(
          name: 'core',
          bundle: salamiCoreBundle,
          help: 'Generate a Salami Flutter application.',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    await installFlutterPackages(logger, outputDir);
    await applyDartFixes(logger, outputDir);
    await installCoverde(logger);
    await installMelos(logger);
    _logSummary(logger);
  }

  void _logSummary(Logger logger) {
    logger
      ..info('\n')
      ..alert('Created a Salami App!')
      ..info('\n');
  }
}

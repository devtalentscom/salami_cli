import 'package:mason/mason.dart';
import 'package:salami_cli/src/commands/create/templates/templates.dart';
import 'package:universal_io/io.dart';

/// {@template salami_page_template}
/// A Flutter page template.
/// {@endtemplate}
class SalamiPageTemplate extends Template {
  /// {@macro salami_page_template}
  SalamiPageTemplate()
      : super(
          name: 'page',
          bundle: salamiPageBundle,
          help: 'Generate a Salami page.',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    _logSummary(logger);
  }

  void _logSummary(Logger logger) {
    logger
      ..info('\n')
      ..alert('Created a Salami Page!')
      ..info('\n');
  }
}

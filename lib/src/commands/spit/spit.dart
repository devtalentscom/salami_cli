import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:salami_cli/src/commands/commands.dart';
import 'package:salami_cli/src/commands/create/templates/templates.dart';
import 'package:universal_io/io.dart';

final _templates = [
  SalamiPageTemplate(),
];

/// {@template spit_command}
/// `salami spit` command creates new component like page/package.
/// {@endtemplate}
class SpitCommand extends Command<int> {
  /// {@macro spit_command}
  SpitCommand({
    Logger? logger,
    GeneratorBuilder? generator,
  })  : _logger = logger ?? Logger(),
        _generate = generator ?? MasonGenerator.fromBundle {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Name of created page',
    );
  }

  final Logger _logger;
  final GeneratorBuilder _generate;

  @override
  final String description = 'Create a new flutter component in seconds.';

  @override
  final String name = 'spit';

  /// [ArgResults] which can be overridden for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  ArgResults get _argResults => argResultOverrides ?? argResults!;

  @override
  Future<int> run() async {
    final outputDirectory = Directory('.');
    final template = _template;
    final name = _name;
    final generateDone = _logger.progress('Bootstrapping');
    final generator = await _generate(template.bundle);
    final fileCount = await generator.generate(
      DirectoryGeneratorTarget(outputDirectory),
      vars: <String, dynamic>{'name': name},
    );
    generateDone.complete('Generated ${fileCount.length} file(s)');

    await template.onGenerateComplete(_logger, outputDirectory);

    return ExitCode.success.code;
  }

  Template get _template {
    final templateName = _argResults.rest;

    _validateTemplateArg(templateName);

    return _templates.firstWhere(
      (element) => element.name == templateName.first.toLowerCase(),
    );
  }

  String get _name {
    var name = _argResults['name'] as String?;
    return name ??= _logger.prompt(
      'Please pass a name for a page:',
      defaultValue: 'salami',
    );
  }

  void _validateTemplateArg(List<String> args) {
    if (args.isEmpty) {
      throw UsageException(
        '''
        No option specified for the template name.
        Please use one of existing templates:
        page - creates new page with cubit''',
        usage,
      );
    }

    if (args.length > 1) {
      throw UsageException('Multiple templates specified.', usage);
    }
    var isExpectedName = false;
    for (final element in _templates) {
      if (element.name == args.first.toLowerCase()) {
        isExpectedName = true;
      }
    }
    if (!isExpectedName) {
      throw UsageException(
        '"${args.first}" is not an allowed value for option template.',
        usage,
      );
    }
  }
}

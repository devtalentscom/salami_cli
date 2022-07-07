import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:salami_cli/src/commands/create/templates/templates.dart';

final _templates = [
  SalamiCoreTemplate(),
];

final _defaultTemplate = _templates.first;

//final RegExp _identifierRegExp = RegExp('[a-z_][a-z0-9_]*');

/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef GeneratorBuilder = Future<MasonGenerator> Function(MasonBundle);

/// {@template create_command}
/// `salami create` command creates a new salami flutter app.
/// {@endtemplate}
class CreateCommand extends Command<int> {
  /// {@macro create_command}
  CreateCommand({
    Logger? logger,
    GeneratorBuilder? generator,
  })  : _logger = logger ?? Logger(),
        _generate = generator ?? MasonGenerator.fromBundle {
    /* argParser
      ..addOption(
        'project-name',
        help: 'The project name for this new Flutter project. '
            'This must be a valid dart package name.',
        defaultsTo: 'salami_app',
      )
      ..addOption(
        'template',
        abbr: 't',
        help: 'The template used to generate this new project.',
        defaultsTo: _defaultTemplate.name,
        allowed: _templates.map((element) => element.name).toList(),
        allowedHelp: _templates.fold<Map<String, String>>(
          {},
          (previousValue, element) => {
            ...previousValue,
            element.name: element.help,
          },
        ),
      ); */
  }

  final Logger _logger;
  final GeneratorBuilder _generate;

  @override
  final String description = 'Creates a new flutter application in seconds.';

  @override
  final String name = 'create';

  /// [ArgResults] which can be overridden for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  ArgResults get _argResults => argResultOverrides ?? argResults!;

  @override
  Future<int> run() async {
    final outputDirectory = _outputDirectory;
    //final projectName = _projectName;
    final template = _template;
    final generateDone = _logger.progress('Bootstrapping');
    final generator = await _generate(template.bundle);
    final fileCount = await generator.generate(
      DirectoryGeneratorTarget(outputDirectory),
      //vars: <String, dynamic>{'project_name': projectName},
    );
    generateDone.complete('Generated ${fileCount.length} file(s)');

    await template.onGenerateComplete(_logger, outputDirectory);

    return ExitCode.success.code;
  }

  /// Gets the project name.
  ///
  /// Uses the current directory path name
  /// if the `--project-name` option is not explicitly specified.
/*   String get _projectName {
    final projectName = _argResults['project-name'] as String;
    _validateProjectName(projectName);
    return projectName;
  }

  void _validateProjectName(String name) {
    final isValidProjectName = _isValidPackageName(name);
    if (!isValidProjectName) {
      throw UsageException(
        '"$name" is not a valid package name.\n\n'
        'See https://dart.dev/tools/pub/pubspec#name for more information.',
        usage,
      );
    }
  } */

  Directory get _outputDirectory {
    final rest = _argResults.rest;
    _validateOutputDirectoryArg(rest);
    return Directory(rest.first);
  }

  void _validateOutputDirectoryArg(List<String> args) {
    if (args.isEmpty) {
      throw UsageException(
        'No option specified for the output directory.',
        usage,
      );
    }

    if (args.length > 1) {
      throw UsageException('Multiple output directories specified.', usage);
    }
  }

/*   /// Whether [name] is a valid Dart package name.
  bool _isValidPackageName(String name) {
    final match = _identifierRegExp.matchAsPrefix(name);
    return match != null && match.end == name.length;
  } */

  Template get _template {
    return _defaultTemplate;
    /* final templateName = _argResults['template'] as String?;

    return _templates.firstWhere(
      (element) => element.name == templateName,
      orElse: () => _defaultTemplate,
    ); */
  }
}

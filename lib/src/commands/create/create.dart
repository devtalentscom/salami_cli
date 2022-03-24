import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:salami_cli/src/commands/create/templates/templates.dart';

final _templates = [
  SalamiCoreTemplate(),
];

final _defaultTemplate = _templates.first;

final RegExp _identifierRegExp = RegExp('[a-z_][a-z0-9_]*');

/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef GeneratorBuilder = Future<MasonGenerator> Function(MasonBundle);

/// {@template create_command}
/// `salami create` command creates a new very good flutter app.
/// {@endtemplate}
class CreateCommand extends Command<int> {
  /// {@macro create_command}
  CreateCommand({
    Logger? logger,
    GeneratorBuilder? generate,
  })  : _logger = logger ?? Logger(),
        _generate = generate ?? MasonGenerator.fromBundle {
    argParser.addOption(
      'project-name',
      help: 'The project name for this new Flutter project. '
          'This must be a valid dart package name.',
      defaultsTo: 'salami_app',
    );
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

  ArgResults? get _argResults => argResultOverrides ?? argResults;

  @override
  Future<int> run() async {
    // ignore: unused_local_variable
    final outputDirectory = _outputDirectory;

    // ignore: unused_local_variable
    final projectName = _projectName;
    final template = _template;
    final generateDone = _logger.progress('Bootstrapping');
    final generator = await _generate(template.bundle);

    final target = DirectoryGeneratorTarget(outputDirectory);
    final fileCount = await generator.generate(
      target,
      vars: <String, dynamic>{'project_name': projectName},
    );
    generateDone('Bootstrapping complete');
    _logger
      ..info(
        '${lightGreen.wrap('✓')} '
        'Generated $fileCount file(s):',
      )
      ..flush(_logger.success)
      ..alert('Created a Salami App!');
    return ExitCode.success.code;
  }

  /// Gets the project name.
  ///
  /// Uses the current directory path name
  /// if the `--project-name` option is not explicitly specified.
  String get _projectName {
    final projectName = (_argResults?['project-name'] ??
            path.basename(path.normalize(_outputDirectory.absolute.path)))
        as String;
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
  }

  Directory get _outputDirectory {
    final rest = _argResults!.rest; // TODO(l-borkowski): change later
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

  /// Whether [name] is a valid Dart package name.
  bool _isValidPackageName(String name) {
    final match = _identifierRegExp.matchAsPrefix(name);
    return match != null && match.end == name.length;
  }

  Template get _template {
    final templateName = _argResults?['template'] as String?;

    return _templates.firstWhere(
      (element) => element.name == templateName,
      orElse: () => _defaultTemplate,
    );
  }
}

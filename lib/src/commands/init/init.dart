import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:salami_cli/src/commands/create/templates/templates.dart';

/// {@template init_command}
/// `salami init` command checks and installs packages if they're missing.
/// {@endtemplate}
class InitCommand extends Command<int> {
  /// {@macro init_command}
  InitCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser
      ..addOption(
        'coverde',
        help: 'Should it install coverde',
        defaultsTo: 'true',
      )
      ..addOption(
        'melos',
        help: 'Should it install melos',
        defaultsTo: 'true',
      )
      ..addOption(
        'fluttergen',
        help: 'Should it install fluttergen',
        defaultsTo: 'true',
      );
  }

  final Logger _logger;

  @override
  final String description = 'Install usefull dart cli tools';

  @override
  final String name = 'init';

  /// [ArgResults] which can be overridden for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  ArgResults get _argResults => argResultOverrides ?? argResults!;

  @override
  Future<int> run() async {
    final coverde = _argResults['coverde'] as String? ?? 'true';
    final melos = _argResults['melos'] as String? ?? 'true';
    final fluttergen = _argResults['fluttergen'] as String? ?? 'true';
    final installing = _logger.progress('Installing');

    if (coverde.toBool()) {
      await installCoverde(_logger);
    }
    if (melos.toBool()) {
      await installMelos(_logger);
    }
    if (fluttergen.toBool()) {
      await installFluttergen(_logger);
    }

    installing.complete('Setup finished');
    _logger
      ..info('\n')
      ..alert("You're ready to go! ⚡")
      ..info('\n');

    return ExitCode.success.code;
  }
}

extension on String {
  bool toBool() => toLowerCase() == 'true';
}

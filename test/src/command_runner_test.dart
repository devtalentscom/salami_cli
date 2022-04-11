// ignore_for_file: no_adjacent_strings_in_list
import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:salami_cli/src/command_runner.dart';
import 'package:salami_cli/src/version.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

class MockPubUpdater extends Mock implements PubUpdater {}

const expectedPrintLogs = [
  '🚀 A Salami Command Line Interface\n'
      '\n'
      'Usage: salami <command> [arguments]\n'
      '\n'
      'Global options:\n'
      '-h, --help       Print this usage information.\n'
      '    --version    Print the current version.\n'
      '\n'
      'Available commands:\n'
      '  create   Creates a new flutter application in seconds.\n'
      '  init     Install usefull dart cli tools\n'
      '  spit     Create a new flutter component in seconds.\n'
      '\n'
      'Run "salami help <command>" for more information about a command.'
];

const responseBody = '{"name": "salami_cli", "versions": ["0.4.0", "0.3.3"]}';

const latestVersion = '0.0.0';

final updatePrompt = '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(packageVersion)} \u2192 ${lightCyan.wrap(latestVersion)}
Run ${lightCyan.wrap('dart pub global activate salami_cli')} to update''';

void main() {
  late List<String> printLogs;
  late Logger logger;
  late SalamiCommandRunner commandRunner;
  late PubUpdater pubUpdater;

  void Function() overridePrint(void Function() fn) {
    return () {
      final spec = ZoneSpecification(
        print: (_, __, ___, String msg) {
          printLogs.add(msg);
        },
      );
      return Zone.current.fork(specification: spec).run<void>(fn);
    };
  }

  setUp(() {
    printLogs = [];
    logger = MockLogger();
    pubUpdater = MockPubUpdater();

    when(
      () => pubUpdater.getLatestVersion(any()),
    ).thenAnswer((_) async => packageVersion);

    commandRunner = SalamiCommandRunner(
      logger: logger,
      pubUpdater: pubUpdater,
    );
  });

  group('SalamiCommandRunner', () {
    test('can be instantiated without an explicit logger instance', () {
      final commandRunner = SalamiCommandRunner();
      expect(commandRunner, isNotNull);
    });

    group('run', () {
      test('shows update message when newer version exists', () async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenAnswer((_) async => latestVersion);

        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.success.code));
        verify(() => logger.info(updatePrompt)).called(1);
      });

      test('handles pub update errors gracefully', () async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenThrow(Exception('oops'));

        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.success.code));
        verifyNever(() => logger.info(updatePrompt));
      });
      test('handles FormatException', () async {
        const exception = FormatException('oops!');
        var isFirstInvocation = true;
        when(() => logger.alert(any())).thenAnswer((_) {
          if (isFirstInvocation) {
            isFirstInvocation = false;
            throw exception;
          }
        });
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(exception.message)).called(1);
        verify(() => logger.info(commandRunner.usage)).called(1);
      });

      test('handles UsageException', () async {
        final exception = UsageException('oops!', commandRunner.usage);
        var isFirstInvocation = true;
        when(() => logger.alert(any())).thenAnswer((_) {
          if (isFirstInvocation) {
            isFirstInvocation = false;
            throw exception;
          }
        });
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(exception.message)).called(1);
        verify(() => logger.info(commandRunner.usage)).called(1);
      });

      test(
        'handles no command',
        overridePrint(() async {
          final result = await commandRunner.run([]);
          expect(printLogs, equals(expectedPrintLogs));
          expect(result, equals(ExitCode.success.code));
        }),
      );

      group('--help', () {
        test(
          'outputs usage',
          overridePrint(() async {
            final result = await commandRunner.run(['--help']);
            expect(printLogs, equals(expectedPrintLogs));
            expect(result, equals(ExitCode.success.code));

            printLogs.clear();

            final resultAbbr = await commandRunner.run(['-h']);
            expect(printLogs, equals(expectedPrintLogs));
            expect(resultAbbr, equals(ExitCode.success.code));
          }),
        );
      });

      group('--version', () {
        test('outputs current version', () async {
          final result = await commandRunner.run(['--version']);
          expect(result, equals(ExitCode.success.code));
          verify(() => logger.info('salami version: $packageVersion'))
              .called(1);
        });
      });
    });
  });
}

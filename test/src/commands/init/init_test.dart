// ignore_for_file: lines_longer_than_80_chars

@Timeout(Duration(seconds: 90))

import 'package:args/args.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salami_cli/src/commands/commands.dart';
import 'package:test/test.dart';

import '../../../helpers/helpers.dart';

const pubspec = '''
name: example
environment:
  sdk: ">=2.13.0 <3.0.0"
''';

const expectedUsage = [
  // ignore: no_adjacent_strings_in_list,
  'Install usefull dart cli tools\n'
      '\n'
      'Usage: salami init [arguments]\n'
      '-h, --help          Print this usage information.\n'
      '    --coverde       Should it install coverde\n'
      '                    (defaults to "true")\n'
      '    --melos         Should it install melos\n'
      '                    (defaults to "true")\n'
      '    --fluttergen    Should it install fluttergen\n'
      '                    (defaults to "true")\n'
      '\n'
      'Run "salami help" to see global options.'
];

class MockArgResults extends Mock implements ArgResults {}

class MockLogger extends Mock implements Logger {}

class FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

class FakeLogger extends Fake implements Logger {}

void main() {
  group('create', () {
    late List<String> progressLogs;
    late Logger logger;

    setUpAll(() {
      registerFallbackValue(FakeDirectoryGeneratorTarget());
      registerFallbackValue(FakeLogger());
    });

    setUp(() {
      progressLogs = <String>[];
      logger = MockLogger();
      when(() => logger.progress(any())).thenReturn(
        ([_]) {
          if (_ != null) progressLogs.add(_);
        },
      );
    });

    test(
      'help',
      withRunner((commandRunner, logger, printLogs) async {
        final result = await commandRunner.run(['init', '--help']);
        expect(printLogs, equals(expectedUsage));
        expect(result, equals(ExitCode.success.code));

        printLogs.clear();

        final resultAbbr = await commandRunner.run(['init', '-h']);
        expect(printLogs, equals(expectedUsage));
        expect(resultAbbr, equals(ExitCode.success.code));
      }),
    );

    test('can be instantiated without explicit logger', () {
      final command = InitCommand();
      expect(command, isNotNull);
    });

    test('completes successfully with correct output', () async {
      final argResults = MockArgResults();
      final command = InitCommand(
        logger: logger,
      )..argResultOverrides = argResults;

      final result = await command.run();
      expect(result, equals(ExitCode.success.code));

      expect(
        progressLogs.elementAt(0),
        equals('Coverde activated'),
      );
      expect(
        progressLogs.elementAt(1),
        equals('Melos activated'),
      );
      expect(
        progressLogs.elementAt(2),
        equals('Setup finished'),
      );

      verify(() => logger.alert("You're ready to go!")).called(1);
    });
  });
}

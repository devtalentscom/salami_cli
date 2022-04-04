// ignore_for_file: lines_longer_than_80_chars

@Timeout(Duration(seconds: 90))

import 'package:args/args.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:salami_cli/src/commands/commands.dart';
import 'package:salami_cli/src/commands/create/templates/templates.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import '../../../helpers/helpers.dart';

const pubspec = '''
name: example
environment:
  sdk: ">=2.13.0 <3.0.0"
''';

const expectedUsage = [
  // ignore: no_adjacent_strings_in_list,
  'Create a new flutter component in seconds.\n'
      '\n'
      'Usage: salami spit [arguments]\n'
      '-h, --help    Print this usage information.\n'
      '-n, --name    Name of created page\n'
      '              (defaults to "salami")\n'
      '\n'
      'Run "salami help" to see global options.'
];

class MockArgResults extends Mock implements ArgResults {}

class MockLogger extends Mock implements Logger {}

class MockMasonGenerator extends Mock implements MasonGenerator {}

class FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

class FakeLogger extends Fake implements Logger {}

void main() {
  group('spit', () {
    late List<String> progressLogs;
    late Logger logger;

    final generatedFiles = List.filled(
      120,
      const GeneratedFile.created(path: ''),
    );

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
        final result = await commandRunner.run(['spit', '--help']);
        expect(printLogs, equals(expectedUsage));
        expect(result, equals(ExitCode.success.code));

        printLogs.clear();

        final resultAbbr = await commandRunner.run(['spit', '-h']);
        expect(printLogs, equals(expectedUsage));
        expect(resultAbbr, equals(ExitCode.success.code));
      }),
    );

    test('can be instantiated without explicit logger', () {
      final command = CreateCommand();
      expect(command, isNotNull);
    });

    test(
      'throws UsageException when template name is missing',
      withRunner((commandRunner, logger, printLogs) async {
        const expectedErrorMessage =
            'No option specified for the template name.';
        final result = await commandRunner.run(['spit']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(expectedErrorMessage)).called(1);
      }),
    );

    test(
      'throws UsageException when multiple names are provided',
      withRunner((commandRunner, logger, printLogs) async {
        const expectedErrorMessage = 'Multiple templates specified.';
        final result = await commandRunner.run(['spit', 'page', 'package']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(expectedErrorMessage)).called(1);
      }),
    );
    test(
      'throws UsageException when invalid template name is provided',
      withRunner((commandRunner, logger, printLogs) async {
        const templateName = 'badtemplate';
        const expectedErrorMessage =
            '''"$templateName" is not an allowed value for option template.''';
        final result = await commandRunner.run(
          ['spit', templateName],
        );
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(expectedErrorMessage)).called(1);
      }),
    );

    test('completes successfully with correct output', () async {
      final argResults = MockArgResults();
      final generator = MockMasonGenerator();
      final command = SpitCommand(
        logger: logger,
        generator: (_) async => generator,
      )..argResultOverrides = argResults;
      when(() => argResults.rest).thenReturn(['page']);
      when(() => generator.id).thenReturn('generator_id');
      when(
        () => generator.generate(
          any(),
          vars: any(named: 'vars'),
          logger: any(named: 'logger'),
        ),
      ).thenAnswer((_) async {
        return generatedFiles;
      });
      final result = await command.run();
      expect(result, equals(ExitCode.success.code));
      verify(() => logger.progress('Bootstrapping')).called(1);
      expect(
        progressLogs.first,
        equals('Generated ${generatedFiles.length} file(s)'),
      );

      verify(() => logger.alert('Created a Salami Page!')).called(1);
    });

    group('template', () {
      group('valid template names', () {
        Future<void> expectValidTemplateName({
          required String templateName,
          required MasonBundle expectedBundle,
          required String expectedLogSummary,
        }) async {
          final argResults = MockArgResults();
          final generator = MockMasonGenerator();
          final command = SpitCommand(
            logger: logger,
            generator: (bundle) async {
              expect(bundle, equals(expectedBundle));
              return generator;
            },
          )..argResultOverrides = argResults;
          when(
            () => argResults['name'] as String?,
          ).thenReturn('salami');
          when(() => argResults.rest).thenReturn([templateName]);
          when(() => generator.id).thenReturn('generator_id');
          when(() => generator.description).thenReturn('generator description');
          when(
            () => generator.generate(
              any(),
              vars: any(named: 'vars'),
              logger: any(named: 'logger'),
            ),
          ).thenAnswer((_) async {
            File(p.join('.tmp', 'pubspec.yaml')).writeAsStringSync(pubspec);
            return generatedFiles;
          });
          final result = await command.run();
          expect(result, equals(ExitCode.success.code));
          verify(() => logger.progress('Bootstrapping')).called(1);
          expect(
            progressLogs.first,
            equals('Generated ${generatedFiles.length} file(s)'),
          );

          verify(() => logger.alert(expectedLogSummary)).called(1);
        }

        test('page template', () async {
          await expectValidTemplateName(
            templateName: 'page',
            expectedBundle: salamiPageBundle,
            expectedLogSummary: 'Created a Salami Page!',
          );
        });
      });
    });
  });
}

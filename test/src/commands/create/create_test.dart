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
  'Creates a new flutter application in seconds.\n'
      '\n'
      'Usage: salami create [arguments]\n'
      '-h, --help    Print this usage information.\n'
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
  group('create', () {
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
        final result = await commandRunner.run(['create', '--help']);
        expect(printLogs, equals(expectedUsage));
        expect(result, equals(ExitCode.success.code));

        printLogs.clear();

        final resultAbbr = await commandRunner.run(['create', '-h']);
        expect(printLogs, equals(expectedUsage));
        expect(resultAbbr, equals(ExitCode.success.code));
      }),
    );

    test('can be instantiated without explicit logger', () {
      final command = CreateCommand();
      expect(command, isNotNull);
    });

/*     test(
      'throws UsageException when --project-name is invalid',
      withRunner((commandRunner, logger, printLogs) async {
        const expectedErrorMessage = '"My App" is not a valid package name.\n\n'
            'See https://dart.dev/tools/pub/pubspec#name for more information.';
        final result = await commandRunner.run(
          ['create', '.', '--project-name', 'My App'],
        );
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(expectedErrorMessage)).called(1);
      }),
    ); */

    test(
      'throws UsageException when output directory is missing',
      withRunner((commandRunner, logger, printLogs) async {
        const expectedErrorMessage =
            'No option specified for the output directory.';
        final result = await commandRunner.run(['create']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(expectedErrorMessage)).called(1);
      }),
    );

    test(
      'throws UsageException when multiple output directories are provided',
      withRunner((commandRunner, logger, printLogs) async {
        const expectedErrorMessage = 'Multiple output directories specified.';
        final result = await commandRunner.run(['create', './a', './b']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(expectedErrorMessage)).called(1);
      }),
    );

    test('completes successfully with correct output', () async {
      final argResults = MockArgResults();
      final generator = MockMasonGenerator();
      final command = CreateCommand(
        logger: logger,
        generator: (_) async => generator,
      )..argResultOverrides = argResults;
      when(() => argResults['project-name'] as String?).thenReturn('my_app');
      when(() => argResults.rest).thenReturn(['.tmp']);
      when(() => generator.id).thenReturn('generator_id');
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
      verify(
        () => logger.progress('Running "flutter packages get" in .tmp'),
      ).called(1);

      expect(
        progressLogs.elementAt(1),
        equals('Coverde activated'),
      );

      expect(
        progressLogs.elementAt(2),
        equals('Melos activated'),
      );

      verify(() => logger.alert('Created a Salami App!')).called(1);
      /* verify(
        () => generator.generate(
          any(
            that: isA<DirectoryGeneratorTarget>().having(
              (g) => g.dir.path,
              'dir',
              '.tmp',
            ),
          ),
          vars: <String, dynamic>{
            'project_name': 'my_app',
          },
          logger: logger,
        ),
      ).called(1); */
    });

    group('--template', () {
/*       group('invalid template name', () {
        test(
          'invalid template name',
          withRunner((commandRunner, logger, printLogs) async {
            const templateName = 'badtemplate';
            const expectedErrorMessage =
                '''"$templateName" is not an allowed value for option "template".''';
            final result = await commandRunner.run(
              ['create', '.', '--template', templateName],
            );
            expect(result, equals(ExitCode.usage.code));
            verify(() => logger.err(expectedErrorMessage)).called(1);
          }),
        );
      }); */

      group('valid template names', () {
        Future<void> expectValidTemplateName({
          required String getPackagesMsg,
          required String templateName,
          required MasonBundle expectedBundle,
          required String expectedLogSummary,
        }) async {
          final argResults = MockArgResults();
          final generator = MockMasonGenerator();
          final command = CreateCommand(
            logger: logger,
            generator: (bundle) async {
              expect(bundle, equals(expectedBundle));
              return generator;
            },
          )..argResultOverrides = argResults;
          when(
            () => argResults['project-name'] as String?,
          ).thenReturn('my_app');
          when(
            () => argResults['template'] as String?,
          ).thenReturn(templateName);
          when(() => argResults.rest).thenReturn(['.tmp']);
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
          verify(
            () => logger.progress(getPackagesMsg),
          ).called(1);
          verify(() => logger.alert(expectedLogSummary)).called(1);
        }

        test('core template', () async {
          await expectValidTemplateName(
            getPackagesMsg: 'Running "flutter packages get" in .tmp',
            templateName: 'core',
            expectedBundle: salamiCoreBundle,
            expectedLogSummary: 'Created a Salami App!',
          );
        });
      });
    });
  });
}

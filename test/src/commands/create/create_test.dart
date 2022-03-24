import 'package:args/args.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:salami_cli/src/command_runner.dart';
import 'package:salami_cli/src/commands/commands.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

const pubspec = '''
name: example
environment:
  sdk: ">=2.13.0 <3.0.0"
''';

class MockArgResults extends Mock implements ArgResults {}

class MockLogger extends Mock implements Logger {}

class MockMasonGenerator extends Mock implements MasonGenerator {}

class FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

class FakeLogger extends Fake implements Logger {}

void main() {
  late List<String> progressLogs;
  late Logger logger;

  final generatedFiles = List.filled(
    62,
    const GeneratedFile.created(path: ''),
  );

  setUpAll(() {
    registerFallbackValue(FakeDirectoryGeneratorTarget());
    registerFallbackValue(FakeLogger());
  });

  when(() => logger.progress(any())).thenReturn(([_]) {});
  late SalamiCommandRunner commandRunner;
  setUp(() {
    progressLogs = <String>[];
    logger = MockLogger();
    commandRunner = SalamiCommandRunner(logger: logger);
  });

  group('Create', () {
    test('can be instantiated without any explicit dependencies', () {
      final commandRunner = CreateCommand();
      expect(commandRunner, isNotNull);
    });

    test('sets salami_app when --project-name is missing ', () async {
      final result = await commandRunner.run(['create', '.tmp']);
      expect(result, equals(ExitCode.success.code));
      verify(() => logger..alert('Created a Salami App!')).called(1);
    });

    test('throws UsageException when --project-name is invalid', () async {
      const expectedErrorMessage = '"My App" is not a valid package name.\n\n'
          'See https://dart.dev/tools/pub/pubspec#name for more information.';
      final result = await commandRunner.run(
        ['create', '.', '--project-name', 'My App'],
      );
      expect(result, equals(ExitCode.usage.code));
      verify(() => logger.err(expectedErrorMessage)).called(1);
    });

    test('throws UsageException when output directory is missing', () async {
      const expectedErrorMessage =
          'No option specified for the output directory.';
      final result = await commandRunner.run(['create']);
      expect(result, equals(ExitCode.usage.code));
      verify(() => logger.err(expectedErrorMessage)).called(1);
    });

    test('throws UsageException when multiple output directories are provided',
        () async {
      const expectedErrorMessage = 'Multiple output directories specified.';
      final result = await commandRunner.run(['create', './a', './b']);
      expect(result, equals(ExitCode.usage.code));
      verify(() => logger.err(expectedErrorMessage)).called(1);
    });

    test('completes successfully with correct output', () async {
      final argResults = MockArgResults();
      final generator = MockMasonGenerator();
      final command = CreateCommand(
        logger: logger,
        generate: (_) async => generator,
      )..argResultOverrides = argResults;
      when(() => argResults['project-name'] as String?).thenReturn('my_app');
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
        progressLogs,
        equals(['Generated ${generatedFiles.length} file(s)']),
      );
      verify(
        () => logger.progress('Running "flutter packages get" in .tmp'),
      ).called(1);
      verify(() => logger.alert('Created a Very Good App! 🦄')).called(1);
      verify(
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
            'org_name': 'com.example.verygoodcore',
            'description': '',
            'android': true,
            'ios': true,
            'web': true,
            'linux': true,
            'macos': true,
            'windows': true,
          },
          logger: logger,
        ),
      ).called(1);
    });
  });
}

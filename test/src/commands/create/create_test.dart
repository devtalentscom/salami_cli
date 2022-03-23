import 'package:io/io.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salami_cli/src/command_runner.dart';
import 'package:salami_cli/src/commands/commands.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  late Logger logger;
  late SalamiCommandRunner commandRunner;
  setUp(() {
    logger = MockLogger();
    commandRunner = SalamiCommandRunner(logger: logger);
  });

  group('Create', () {
    test('can be instantiated without an explicit Logger instance', () {
      final commandRunner = CreateCommand();
      expect(commandRunner, isNotNull);
    });

    test('throws UsageException when --project-name is invalid', () async {
      const expectedErrorMessage = '"My App" is not a valid package name.\n\n'
          'See https://dart.dev/tools/pub/pubspec#name for more information.';
      final result = await commandRunner.run(
        ['create', '--project-name', 'My App'],
      );
      expect(result, equals(ExitCode.usage.code));
      verify(() => logger.err(expectedErrorMessage)).called(1);
    });

    test('completes successfully with correct output', () async {
      final result = await commandRunner.run(
        ['create', '--project-name', 'my_app'],
      );
      expect(result, equals(ExitCode.success.code));
      verify(() => logger.alert('Created a Very Good App! 🦄')).called(1);
    });
  });
}

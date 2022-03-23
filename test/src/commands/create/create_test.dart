import 'package:io/io.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salami_cli/src/commands/commands.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  late Logger logger;
  late CreateCommand command;
  setUp(() {
    logger = MockLogger();
    command = CreateCommand(logger: logger);
  });

  group('Create', () {
    test('can be instantiated without an explicit Logger instance', () {
      final command = CreateCommand();
      expect(command, isNotNull);
    });

    test('completes successfully with correct output', () async {
      final result = await command.run();
      expect(result, equals(ExitCode.success.code));
      verify(() => logger.alert('Created a Very Good App! 🦄')).called(1);
    });
  });
}

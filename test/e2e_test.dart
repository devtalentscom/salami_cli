@Tags(['e2e'])
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:salami_cli/src/command_runner.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

class MockLogger extends Mock implements Logger {}

class MockProgress extends Mock implements Progress {}

void main() {
  group(
    'E2E',
    () {
      late Logger logger;
      late SalamiCommandRunner commandRunner;
      late Progress progress;

      void _removeTemporaryFiles() {
        try {
          Directory('.tmp').deleteSync(recursive: true);
        } catch (_) {}
      }

      setUpAll(_removeTemporaryFiles);
      tearDownAll(_removeTemporaryFiles);

      setUp(() {
        logger = MockLogger();
        progress = MockProgress();

        when(() => logger.progress(any())).thenReturn(progress);

        commandRunner = SalamiCommandRunner(
          logger: logger,
        );
      });

      test('create -t core', () async {
        final directory = Directory(path.join('.tmp', 'salami_core'));

        final result = await commandRunner.run(
          ['create', directory.path],
        );
        expect(result, equals(ExitCode.success.code));

        final formatResult = await Process.run(
          'flutter',
          ['format', '--set-exit-if-changed', '.'],
          workingDirectory: directory.path,
          runInShell: true,
        );
        expect(formatResult.exitCode, equals(ExitCode.success.code));
        expect(formatResult.stderr, isEmpty);

        final analyzeResult = await Process.run(
          'flutter',
          ['analyze', '.'],
          workingDirectory: directory.path,
          runInShell: true,
        );
        expect(analyzeResult.exitCode, equals(ExitCode.success.code));
        expect(analyzeResult.stderr, isEmpty);
        expect(analyzeResult.stdout, contains('No issues found!'));

        final testResult = await Process.run(
          'melos',
          ['workflow_test'],
          workingDirectory: directory.path,
          runInShell: true,
        );
        expect(testResult.exitCode, equals(ExitCode.success.code));
        expect(testResult.stdout, contains('All tests passed!'));

        final testCoverageResult = await Process.run(
          'coverde',
          ['value', '-i', 'coverage/filtered.lcov.info', '--no-verbose'],
          workingDirectory: directory.path,
          runInShell: true,
        );
        expect(testCoverageResult.exitCode, equals(ExitCode.success.code));
        expect(testCoverageResult.stderr, isEmpty);
        expect(testCoverageResult.stdout, contains('100.00% - 114/114'));
      });
    },
    timeout: const Timeout(Duration(seconds: 180)),
  );
}

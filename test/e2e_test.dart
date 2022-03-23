@Tags(['e2e'])
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  group(
    'E2E',
    () {
      test('initial test', () {});
    },
    timeout: const Timeout(Duration(seconds: 90)),
  );
}

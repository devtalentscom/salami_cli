import 'package:salami_cli/src/cli/cli.dart';
import 'package:test/test.dart';

void main() {
  group('Dart', () {
    group('.installed', () {
      test('returns true when dart is installed', () {
        expectLater(Dart.installed(), completion(isTrue));
      });
    });

    group('.applyFixes', () {
      test('completes normally', () {
        expectLater(Dart.applyFixes(), completes);
      });
    });
  });
}

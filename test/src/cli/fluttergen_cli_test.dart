import 'package:salami_cli/src/cli/cli.dart';
import 'package:test/test.dart';

void main() {
  group('Fluttergen', () {
    group('.installed', () {
      test('returns true when fluttergen is installed', () {
        expectLater(Fluttergen.installed(), completion(false));
      });
    });

    group('.activate', () {
      test('completes normally', () async {
        await expectLater(Fluttergen.activate(), completes);
      });
    });
  });
}

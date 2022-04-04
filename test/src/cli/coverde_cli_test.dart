import 'package:salami_cli/src/cli/cli.dart';
import 'package:test/test.dart';

void main() {
  group('Coverde', () {
    group('.installed', () {
      test('returns true when coverde is installed', () {
        expectLater(Coverde.installed(), completion(false));
      });
    });

    group('.activate', () {
      test('completes normally', () async {
        await expectLater(Coverde.activate(), completes);
      });
    });
  });
}

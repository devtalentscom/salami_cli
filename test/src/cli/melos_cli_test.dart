import 'package:salami_cli/src/cli/cli.dart';
import 'package:test/test.dart';

void main() {
  group('Melos', () {
    group('.installed', () {
      test('returns true when melos is installed', () {
        expectLater(Melos.installed(), completion(true));
      });
    });

    group('.activate', () {
      test('completes normally', () async {
        await expectLater(Melos.activate(), completes);
      });
    });
  });
}

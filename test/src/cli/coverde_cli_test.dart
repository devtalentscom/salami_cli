import 'package:salami_cli/src/cli/cli.dart';
import 'package:test/test.dart';

void main() {
  Future<void> deactivate() async {
    await Coverde.activate();
    await Coverde.deactivate();
  }

  tearDownAll(deactivate);
  group('Coverde', () {
    group('.installed', () {
      setUp(deactivate);
      test('returns false when coverde is not present', () {
        expectLater(Coverde.installed(), completion(false));
      });
    });

    group('.activate', () {
      setUp(deactivate);
      test('completes normally', () async {
        await expectLater(Coverde.activate(), completes);
      });
    });

    group('.deactivate', () {
      setUp(Coverde.activate);
      test('completes normally', () async {
        await expectLater(Coverde.deactivate(), completes);
      });
    });
  });
}

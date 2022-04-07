import 'package:salami_cli/src/cli/cli.dart';
import 'package:test/test.dart';

void main() {
  Future<void> deactivate() async {
    await Melos.activate();
    await Melos.deactivate();
  }

  tearDownAll(deactivate);

  group('Melos', () {
    group('.installed', () {
      setUp(deactivate);
      test('returns false when melos is not present', () {
        expectLater(Melos.installed(), completion(false));
      });
    });

    group('.activate', () {
      setUp(deactivate);
      test('completes normally', () async {
        await expectLater(Melos.activate(), completes);
      });
    });

    group('.deactivate', () {
      setUp(Melos.activate);
      test('completes normally', () async {
        await expectLater(Melos.deactivate(), completes);
      });
    });
  });
}

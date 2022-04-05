import 'package:salami_cli/src/cli/cli.dart';
import 'package:test/test.dart';

void main() {
  Future<void> deactivate() async {
    await Fluttergen.activate();
    await Fluttergen.deactivate();
  }

  tearDownAll(deactivate);
  group('Fluttergen', () {
    group('.installed', () {
      setUp(deactivate);
      test('returns false when melos is not present', () {
        expectLater(Fluttergen.installed(), completion(false));
      });
    });

    group('.activate', () {
      setUp(deactivate);
      test('completes normally', () async {
        await expectLater(Fluttergen.activate(), completes);
      });
    });

    group('.deactivate', () {
      setUp(Fluttergen.activate);
      test('completes normally', () async {
        await expectLater(Fluttergen.deactivate(), completes);
      });
    });
  });
}

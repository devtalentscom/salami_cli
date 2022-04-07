import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salami_cli/src/cli/cli.dart';
import 'package:salami_cli/src/commands/create/templates/templates.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

class FakeLogger extends Fake implements Logger {}

void main() {
  Future<void> deactivate() async {
    await Melos.activate();
    await Melos.deactivate();
    await Coverde.activate();
    await Coverde.deactivate();
    await Fluttergen.activate();
    await Fluttergen.deactivate();
  }

  group('post generate actions', () {
    late List<String> progressLogs;
    late Logger logger;

    setUpAll(() {
      registerFallbackValue(FakeLogger());
    });

    setUp(() {
      progressLogs = <String>[];
      logger = MockLogger();
      when(() => logger.progress(any())).thenReturn(
        ([_]) {
          if (_ != null) progressLogs.add(_);
        },
      );
    });

    group('without activated cli tools', () {
      setUpAll(deactivate);
      test('installMelos', () async {
        await installMelos(logger);

        verify(
          () => logger.progress('Checking if melos is activated'),
        ).called(1);

        verify(
          () => logger.progress('Running "dart pub global activate melos"'),
        ).called(1);

        expect(
          progressLogs.elementAt(0),
          equals('Melos activated'),
        );
      });
      test('installCoverde', () async {
        await installCoverde(logger);

        verify(
          () => logger.progress('Checking if coverde is activated'),
        ).called(1);

        verify(
          () => logger.progress('Running "dart pub global activate coverde"'),
        ).called(1);

        expect(
          progressLogs.elementAt(0),
          equals('Coverde activated'),
        );
      });
      test('installFluttergen', () async {
        await installFluttergen(logger);

        verify(
          () => logger.progress('Checking if fluttergen is activated'),
        ).called(1);

        verify(
          () =>
              logger.progress('Running "dart pub global activate flutter_gen"'),
        ).called(1);

        expect(
          progressLogs.elementAt(0),
          equals('Fluttergen activated'),
        );
      });
    });

    group('with activated cli tools', () {
      setUp(
        () async {
          await Melos.activate();
          await Coverde.activate();
          await Fluttergen.activate();
        },
      );
      test('installMelos', () async {
        await installMelos(logger);

        verify(
          () => logger.progress('Checking if melos is activated'),
        ).called(1);

        expect(
          progressLogs.first,
          equals('Melos activated'),
        );
      });
      test('installCoverde', () async {
        await installCoverde(logger);

        verify(
          () => logger.progress('Checking if coverde is activated'),
        ).called(1);

        expect(
          progressLogs.first,
          equals('Coverde activated'),
        );
      });
      test('installFluttergen', () async {
        await installFluttergen(logger);

        verify(
          () => logger.progress('Checking if fluttergen is activated'),
        ).called(1);

        expect(
          progressLogs.first,
          equals('Fluttergen activated'),
        );
      });
    });
  });
}

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:salami_cli/src/cli/cli.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

const otherContents = '''
class Other {
  void foo() {
    print('hello world');
  }
}''';

const calculatorContents = '''
class Calculator {
  int add(int x, int y) => x + y;
  int subtract(int x, int y) => x - y;
}''';

const calculatorTestContents = '''
import 'package:test/test.dart';
import 'package:example/calculator.dart';

void main() {
  test('...', () {
    expect(Calculator().add(1, 2), equals(3));
    expect(Calculator().subtract(43, 1), equals(42));
  });
}''';

const calculatorTestContentsMissingCoverage = '''
import 'package:test/test.dart';
import 'package:example/calculator.dart';

void main() {
  test('...', () {
    expect(Calculator().add(1, 2), equals(3));
  });
}''';

const calculatorTestContentsWithOtherImport = '''
import 'package:test/test.dart';
import 'package:example/calculator.dart';
import 'package:example/other.dart';

void main() {
  test('...', () {
    expect(Calculator().add(1, 2), equals(3));
    expect(Calculator().subtract(43, 1), equals(42));
  });
}''';

const testContents = '''
import 'package:test/test.dart';

void main() {
  test('example', () {
    expect(true, isTrue);
  });
}''';

const longTestNameContents = '''
import 'package:test/test.dart';

void main() {
  test('reeeeeaaaaalllllllllyyyyyyyyyyyloooonnnnnnngggggggggtestttttttttttttttnameeeeeeeeeeeeeeeee', () {
    expect(true, isTrue);
  });
}''';

const extraLongTestNameContents = '''
import 'package:test/test.dart';

void main() {
  test('reeeeeaaaaalllllllllyyyyyyyyyyyloooonnnnnnngggggggggtestttttttttttttttnameeeeeeeeeeeeeeeee', () {
    expect(true, isTrue);
  });

  test('extraaaaaareeeeeaaaaalllllllllyyyyyyyyyyyloooonnnnnnngggggggggtestttttttttttttttnameeeeeeeeeeeeeeeee', () {
    expect(true, isFalse);
  });

  test('superrrrrrr  extraaaaaa  reeeeeaaaaalllllllllyyyyyyyyyyy   loooonnnnnnnggggggggg    testtttttttttttttt  nameeeeeeeeeeeeeeeee', () {
    expect(true, isFalse);
  }, skip: true);
}''';

const loggingTestContents = '''
import 'package:test/test.dart';

void main() {
  test('example', () {
    print('Hello World!');
    expect(true, isTrue);
  });
}''';

const failingTestContents = '''
import 'package:test/test.dart';
void main() {
  test('example', () {
    expect(true, isFalse);
  });
}''';

const exceptionTestContents = '''
import 'package:test/test.dart';
void main() {
  test('example', () {
    print('EXCEPTION');
    throw Exception('oops');
  });
}''';

const skippedTestContents = '''
import 'package:test/test.dart';
void main() {
  test('skipped example', () {
    expect(true, isTrue);
  }, skip: true);

  test('example', () {
    expect(true, isTrue);
  });
}''';

const tagsTestContents = '''
import 'package:test/test.dart';
void main() {
  test('skipped example', () {
    expect(true, isTrue);
  }, tags: 'pr-only');

  test('example', () {
    expect(true, isTrue);
  });
}''';

const dartTestYamlContents = '''
tags:
  pr-only:
    skip: "Should only be run during pull request"  
''';

const pubspec = '''
name: example
environment:
  sdk: ">=2.13.0 <3.0.0"

dev_dependencies:
  test: any''';

const invalidPubspec = 'name: example';

class MockLogger extends Mock implements Logger {}

void main() {
  group('Flutter', () {
    group('.packagesGet', () {
      test('throws when there is no pubspec.yaml', () {
        expectLater(
          Flutter.packagesGet(cwd: Directory.systemTemp.path),
          throwsException,
        );
      });

      test('throws when process fails', () {
        final directory = Directory.systemTemp.createTempSync();
        File(p.join(directory.path, 'pubspec.yaml'))
            .writeAsStringSync(invalidPubspec);

        expectLater(
          Flutter.packagesGet(cwd: directory.path),
          throwsException,
        );
      });

      test('completes when there is a pubspec.yaml', () async {
        await expectLater(Flutter.packagesGet(), completes);
      });

      test('throws when there is no pubspec.yaml (recursive)', () {
        final directory = Directory.systemTemp.createTempSync();
        expectLater(
          Flutter.packagesGet(cwd: directory.path, recursive: true),
          throwsException,
        );
      });

      test('completes when there is a pubspec.yaml (recursive)', () {
        final directory = Directory.systemTemp.createTempSync();
        final nestedDirectory = Directory(p.join(directory.path, 'test'))
          ..createSync();
        File(p.join(nestedDirectory.path, 'pubspec.yaml'))
            .writeAsStringSync(pubspec);
        expectLater(
          Flutter.packagesGet(cwd: directory.path, recursive: true),
          completes,
        );
      });
    });

    group('.pubGet', () {
      test('throws when there is no pubspec.yaml', () {
        expectLater(
          Flutter.pubGet(cwd: Directory.systemTemp.path),
          throwsException,
        );
      });

      test('throws when process fails', () {
        final directory = Directory.systemTemp.createTempSync();
        File(p.join(directory.path, 'pubspec.yaml'))
            .writeAsStringSync(invalidPubspec);

        expectLater(
          Flutter.pubGet(cwd: directory.path),
          throwsException,
        );
      });

      test('completes when there is a pubspec.yaml', () {
        final directory = Directory.systemTemp.createTempSync();
        File(p.join(directory.path, 'pubspec.yaml')).writeAsStringSync(pubspec);
        expectLater(Flutter.pubGet(cwd: directory.path), completes);
      });

      test('throws when there is no pubspec.yaml (recursive)', () {
        final directory = Directory.systemTemp.createTempSync();
        expectLater(
          Flutter.pubGet(cwd: directory.path, recursive: true),
          throwsException,
        );
      });

      test('completes when there is a pubspec.yaml (recursive)', () {
        final directory = Directory.systemTemp.createTempSync();
        final nestedDirectory = Directory(p.join(directory.path, 'test'))
          ..createSync();
        File(p.join(nestedDirectory.path, 'pubspec.yaml'))
            .writeAsStringSync(pubspec);
        expectLater(
          Flutter.pubGet(cwd: directory.path, recursive: true),
          completes,
        );
      });
    });
  });
}

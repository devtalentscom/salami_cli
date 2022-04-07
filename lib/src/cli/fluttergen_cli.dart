part of 'cli.dart';

/// Fluttergen CLI
class Fluttergen {
  /// Determine whether fluttergen is installed.
  static Future<bool> installed() async {
    try {
      await _Cmd.run('fluttergen', ['--version']);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Install fluttergen (`dart pub global activate fluttergen`).
  static Future<void> activate() async {
    await _Cmd.run(
      'dart',
      ['pub', 'global', 'activate', 'flutter_gen'],
    );
  }

  /// Uninstall fluttergen (`dart pub global deactivate fluttergen`).
  @visibleForTesting
  static Future<void> deactivate() async {
    await _Cmd.run(
      'dart',
      ['pub', 'global', 'deactivate', 'flutter_gen'],
    );
  }
}

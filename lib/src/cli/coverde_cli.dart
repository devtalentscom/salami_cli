part of 'cli.dart';

/// Coverde CLI
class Coverde {
  /// Determine whether coverde is installed.
  static Future<bool> installed() async {
    try {
      await _Cmd.run('coverde', ['--help']);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Install coverde (`dart pub global activate coverde`).
  static Future<void> activate() async {
    await _Cmd.run(
      'dart',
      ['pub', 'global', 'activate', 'coverde'],
    );
  }

  /// Uninstall coverde (`dart pub global deactivate coverd`).
  @visibleForTesting
  static Future<void> deactivate() async {
    await _Cmd.run(
      'dart',
      ['pub', 'global', 'deactivate', 'coverde'],
    );
  }
}

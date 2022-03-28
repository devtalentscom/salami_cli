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
  static Future<void> activate({
    String cwd = '.',
    bool recursive = false,
  }) async {
    await _runCommand(
      cmd: (cwd) async {
        await _Cmd.run(
          'dart',
          ['pub', 'global', 'activate', 'coverde'],
          workingDirectory: cwd,
        );
      },
      cwd: cwd,
      recursive: recursive,
    );
  }
}

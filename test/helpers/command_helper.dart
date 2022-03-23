import 'dart:async';

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salami_cli/src/command_runner.dart';

class MockLogger extends Mock implements Logger {}

void Function() _overridePrint(void Function(List<String>) fn) {
  return () {
    final printLogs = <String>[];
    final spec = ZoneSpecification(
      print: (_, __, ___, String msg) {
        printLogs.add(msg);
      },
    );

    return Zone.current
        .fork(specification: spec)
        .run<void>(() => fn(printLogs));
  };
}

void Function() withRunner(
  FutureOr<void> Function(
    SalamiCommandRunner commandRunner,
    Logger logger,
    List<String> printLogs,
  )
      runnerFn,
) {
  return _overridePrint((printLogs) async {
    final logger = MockLogger();
    final commandRunner = SalamiCommandRunner(
      logger: logger,
    );

    await runnerFn(commandRunner, logger, printLogs);
  });
}

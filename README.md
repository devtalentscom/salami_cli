# Salami CLI

Developed with 💙 by [DevTalents](dev_talents_link)

![coverage][coverage_badge]
[![License: MIT][license]](license_link)
[![style: very_good_analysis_link][badge]][badge_link]

A Salami Command Line Interface for Dart.

## Installing

```sh
dart pub global activate salami_cli
```

## Commands

See the complete list of commands and usage information.

```sh
🚀 A Salami Command Line Interface
Usage: salami <command> [arguments]
Global options:
-h, --help       Print this usage information.
    --version    Print the current version.
Available commands:
  create   Creates a new salami flutter application in seconds.
  init     Install usefull dart cli tools
  spit     Create a new flutter component in seconds.
Run "salami help <command>" for more information about a command.
```

#### Usage

```sh
# Create a new Flutter app in current directory
salami create .

# Create a new Flutter app in passed directory
salami create ./foo/bar

# Install all cli tools used in salami core lika coverde, melos etc.
salami init

# Create flutter page with cubit and tests.
salami spit page -n home
```

---

[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/very_good_cli/main/coverage_badge.svg
[badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[badge_link]: https://pub.dev/packages/very_good_analysis
[license]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_link]: https://github.com/VeryGoodOpenSource/very_good_analysis
[dev_talents_link]: https://unitedideas.co/

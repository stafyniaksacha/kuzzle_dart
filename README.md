[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![Pub](https://img.shields.io/pub/v/kuzzle.svg?style=flat-square)](https://pub.dartlang.org/packages/kuzzle)
[![codecov](https://img.shields.io/codecov/c/github/prijindal/kuzzle_dart/master.svg?style=flat-square)](https://codecov.io/gh/prijindal/kuzzle_dart)
[![Build Status](https://img.shields.io/travis/prijindal/kuzzle_dart/master.svg?style=flat-square)](https://travis-ci.org/prijindal/kuzzle_dart)

# Kuzzle Dart SDK

## About Kuzzle

A backend software, self-hostable and ready to use to power modern apps.

You can access the Kuzzle repository on [Github](https://github.com/kuzzleio/kuzzle) or view official website [kuzzle.io](https://kuzzle.io).

* [Installation](#installation)
* [Basic usage](#basic-usage)
* [Documentation and Samples](#documentation-and-samples)
* [Contribution](#contribution)

## Installation

Include this in your pubspec.yaml

```yaml
dependencies:
  kuzzle: ^1.0.0-alpha.4

```

## Basic usage

```dart
import 'package:kuzzle/kuzzle.dart';

final kuzzle = Kuzzle(
  WebSocketProtocol('127.0.0.1.xip.io'),
  offlineMode: OfflineMode.auto,
);

void main () async {
  // note that we don't need to await connection to be effective
  kuzzle.connect(); 
  
  final result = await kuzzle.server.info();
  print('[result][server][info] $result');
}
```

> only `WebSocketProtocol` protocol is available for now, feel free to suggest a PR for other protocols submissions

## Documentation and Samples

* [https://prijindal.github.io/kuzzle_dart/](https://prijindal.github.io/kuzzle_dart/) - 
  _Access the auto generated documentation from source code_
* [https://docs-v2.kuzzle.io/api](https://docs-v2.kuzzle.io/api) - 
  _Official Kuzzle API documentation_
* [example/ folder](./example/) - 
  _Various samples about using this library_
  
## Contributions

If you find a bug or want a feature, but don't know how to fix/implement it, feel free to open an issue.
If you fixed a bug or implemented a new feature, we will enjoy to merge your pull request.

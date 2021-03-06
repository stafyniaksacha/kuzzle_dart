#!/bin/sh
mkdir coverage
dart --pause-isolates-on-exit --enable_asserts --enable-vm-service test/.test_coverage.dart &
sleep 30
pub run coverage:collect_coverage --uri=http://127.0.0.1:8181 -o coverage/coverage.json --resume-isolates
pub run coverage:format_coverage -l --packages=$(pwd)/.packages -i coverage/coverage.json --report-on=lib -o coverage/lcov.info
curl -s https://codecov.io/bash > coverage/.codecov
sed -i -e 's/TRAVIS_.*_VERSION/^TRAVIS_.*_VERSION=/' coverage/.codecov
chmod +x coverage/.codecov
./coverage/.codecov

killall dart
wait
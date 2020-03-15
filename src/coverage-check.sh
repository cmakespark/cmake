#!/bin/sh

export COVERAGE=$(lcov --summary coverage.info 2>&1 | grep lines | xargs | cut -d ' ' -f 2 | cut -d '.' -f 1)
test $COVERAGE -ge $1

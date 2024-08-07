#!/usr/bin/env bash

set -euo pipefail

GOOS="linux" go build -ldflags='-s -w' -o bin/helper github.com/initializ-buildpacks/apache-tomcat/v7/cmd/helper
GOOS="linux" go build -ldflags='-s -w' -o bin/main github.com/initializ-buildpacks/apache-tomcat/v7/cmd/main

if [ "${STRIP:-false}" != "false" ]; then
  strip bin/helper bin/main
fi

if [ "${COMPRESS:-none}" != "none" ]; then
  $COMPRESS bin/helper bin/main
fi

ln -fs main bin/build
ln -fs main bin/detect

#!/usr/bin/env bash
set -e

mkdir -p tools/bin || true

if ! which hammer; then
    go get -v github.com/asteris-llc/hammer
    go build -o tools/bin/hammer github.com/asteris-llc/hammer
fi

gem install fpm # TODO: cache me!

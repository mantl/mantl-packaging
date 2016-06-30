#!/usr/bin/env bash
set -e

mkdir -p tools/bin || true

if ! which hammer; then
    go get -v github.com/asteris-llc/hammer
    go build -o tools/bin/hammer github.com/asteris-llc/hammer
fi

which fpm || gem install fpm # TODO: cache me!

export PATH=tools/bin:$PATH

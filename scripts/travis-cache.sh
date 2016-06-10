#!/usr/bin/env bash
set -e

echo "Go platform version is: $(go version)"

if [[ $PACKAGE == "distributive" ]] && ! which glide; then
  go get -v github.com/Masterminds/glide
  go build -o tools/bin/glide github.com/Masterminds/glide
fi

mkdir -p tools/bin || true

if ! which hammer; then
    go get -v github.com/asteris-llc/hammer
    go build -o tools/bin/hammer github.com/asteris-llc/hammer
fi

which fpm || gem install fpm # TODO: cache me!

export PATH=tools/bin:$PATH

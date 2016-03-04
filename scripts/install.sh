#!/usr/bin/env bash

if [[ $PACKAGE == "distributive" ]] && ! which godep; then
  go get -v github.com/tools/godep
  go build -o tools/bin/godep github.com/tools/godep
fi

mkdir -p tools/bin || true

if ! which hammer; then
  go get -v github.com/asteris-llc/hammer
  go build -o tools/bin/hammer github.com/asteris-llc/hammer
fi

# TODO: cache fpm
! which fpm; gem install fpm

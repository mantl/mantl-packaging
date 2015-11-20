#!/usr/bin/env bash
set -e

LAST_FILE=.build-info/last-build

# set build cache if not set
[[ ! -f $LAST_FILE ]] && git rev-list --max-parents=0 HEAD > $LAST_FILE

LAST=$(cat .build-info/last-build)
CURRENT=$(git rev-parse HEAD)
NAMES=$(python scripts/names.py $LAST $CURRENT)

if [[ "$NAMES" == "" ]]; then
    echo "no changed packages found";
else
    echo "changed packages found: $NAMES"
    hammer build --output=/tmp/out $NAMES
fi

echo $CURRENT > $LAST_FILE

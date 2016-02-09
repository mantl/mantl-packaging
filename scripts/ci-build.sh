#!/usr/bin/env bash

###################
## SHORT-CIRCUIT ##
###################

# put "ci: all" in any commit message to build all the packages
if $(git log $TRAVIS_COMMIT_RANGE | grep -q 'ci: all'); then
    echo "found 'ci: all', building"
else
    echo "no 'ci: all' found in any range commit message, evaluating whether or not to build based on changed files"

    CHANGED_FILES=$(git diff --name-only $TRAVIS_COMMIT_RANGE)
    PACKAGE_ROOT=$(grep "|$PACKAGE|" ./scripts/paths | cut -f 2 -d ' ')

    if ! $(echo $CHANGED_FILES | grep -q $PACKAGE_ROOT); then
        echo "exiting now because there are no changed files in ${TRAVIS_COMMIT_RANGE} for ${PACKAGE}"
        exit 0
    fi
fi

#############
## INSTALL ##
#############

./scripts/travis-cache.sh

###########
## BUILD ##
###########

mkdir /tmp/out
PATH=tools/bin:$PATH hammer build --output=/tmp/out --stream-logs-for=$PACKAGE $PACKAGE

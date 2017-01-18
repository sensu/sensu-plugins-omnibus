#!/bin/bash

set -e

if [ "x${BUILD_PLATFORM}" == "x" ]; then
    echo "!!! BUILD_PLATFORM not set, exiting."
    exit
fi

OMNIBUS_COMMIT=`git rev-parse HEAD`

if [ `git describe --tags --exact-match $OMNIBUS_COMMIT` ]; then
    export SENSU_VERSION=`git describe --abbrev=0 --tags | awk -F'-' '{print $1}' | sed 's/v//g'`
    export BUILD_NUMBER=`git describe --abbrev=0 --tags | awk -F'-' '{print $2}'`
    echo "============================ Building ${SENSU_VERSION}-${BUILD_NUMBER} on ${BUILD_PLATFORM} ============================"
    bundle exec rake kitchen:default-$BUILD_PLATFORM
else
    echo "!!! Commit ${OMNIBUS_COMMIT} is not tagged, exiting."
    exit
fi
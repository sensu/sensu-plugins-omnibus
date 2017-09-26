#!/bin/bash

set -e

docker run -P \
       --name sensu-plugins-$PLATFORM-$PLATFORM_VERSION \
       -v $PWD:/opt/sensu-plugins-omnibus \
       -e PLATFORM=$PLATFORM \
       -e PLATFORM_VERSION=$PLATFORM_VERSION \
       -e KERNEL_ARCH=$KERNEL_ARCH \
       -it --rm \
       $PLATFORM:$PLATFORM_VERSION \
       /opt/sensu-plugins-omnibus/docker-build.sh

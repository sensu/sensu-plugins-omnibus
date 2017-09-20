#!/bin/bash

set -e

sudo apt-get install -y fakeroot gcc-multilib g++-multilib
bundle exec omnibus build sensu_plugins -l debug
dpkg-deb -I pkg/*.deb

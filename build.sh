#!/bin/bash

set -e

sudo apt-get install -y fakeroot
bundle exec omnibus build sensu_plugins -l debug

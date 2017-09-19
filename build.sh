#!/bin/bash

set -e

bundle exec omnibus build sensu_plugins -l debug

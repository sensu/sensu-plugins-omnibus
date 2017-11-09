#!/usr/bin/env bash

/opt/sensu-plugins-ruby/embedded/bin/gem install $@

mkdir -p /tmp/assets

cd /opt/sensu-plugins-ruby/embedded && tar -cvf /tmp/assets/sensu-plugins.tar *

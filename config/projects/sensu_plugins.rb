#
# Copyright 2017 Sensu, Inc.
#
# All Rights Reserved.
#

name "sensu-plugins-ruby"
homepage "https://sensu.io"
license "MIT"
description "A monitoring framework that aims to be simple, malleable, and scalable."

if windows?
  maintainer "Sensu, Inc."
else
  maintainer "support@sensu.io"
end

vendor = "Sensu <support@sensu.io>"

# Defaults to C:/opt/sensu on Windows
# and /opt/sensu on all other platforms
if windows?
  install_dir "#{default_root}/opt/#{name}"
else
  install_dir "#{default_root}/#{name}"
end

version = "0.1.0"
build_version version
build_iteration 3000

override "ruby", version: "2.4.1"
override "rubygems", version: "2.6.10"

package :deb do
  section "Monitoring"
  vendor vendor
end

platform_version = ohai["platform_version"]

package :rpm do
  category "Monitoring"
  vendor vendor
  #if Gem::Version.new(platform_version) >= Gem::Version.new(6)
  #  signing_passphrase gpg_passphrase
  #end
end

package :msi do
  upgrade_code "29B5AA66-46B3-4676-8D67-2F3FB31CC549"
  wix_light_extension "WixNetFxExtension"
end

proj_to_work_around_cleanroom = self
package :pkg do
  identifier "io.sensu.pkg.#{proj_to_work_around_cleanroom.name}"
  #signing_identity "Developer ID Installer: Sensu, Inc. (IDHERE)"
end
compress :dmg

# Creates required build directories
dependency "preparation"

# ruby & rubygem dependencies/components
dependency "ruby"
dependency "rubygems"

# Make sure Windows gets a gem.bat
dependency "shebang-cleanup" if windows?

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

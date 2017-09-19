#
# Cookbook Name:: omnibus_sensu
# Recipe:: default
#
# Copyright (c) 2016 Sensu, All Rights Reserved.

include_recipe 'chef-sugar'

if windows?
  include_recipe 'chocolatey'

  chocolatey 'dotnet3.5' do
    version '3.5.20160716'
  end

  chocolatey 'windows-sdk-8.1' do
    version '8.100.26654.0'
  end

  chocolatey 'microsoft-build-tools' do
    version '14.0.25420.1'
  end

  chocolatey 'awscli' do
    version '1.11.41'
  end

  # If this is an ephemeral vagrant/test-kitchen instance, we relax the password
  # so that the default password "vagrant" can be used.
  powershell_script 'Disable password complexity requirements' do
    code <<-EOH
      secedit /export /cfg $env:temp/export.cfg
      ((get-content $env:temp/export.cfg) -replace ('PasswordComplexity = 1', 'PasswordComplexity = 0')) | Out-File $env:temp/export.cfg
      secedit /configure /db $env:windir/security/new.sdb /cfg $env:temp/export.cfg /areas SECURITYPOLICY
    EOH
  end
end

if freebsd?
  package "git"
else
  include_recipe "git"

  git_config "user.email" do
    value "support@sensuapp.com"
    options "--global"
  end

  git_config "user.name" do
    value "Sensu Omnibus Builder"
    options "--global"
  end
end

include_recipe "omnibus::default"

# case node["platform_family"]
# when "rhel"
#   # skip signing on Centos 5 because of Reasons
#   if Gem::Version.new(node["platform_version"]) >= Gem::Version.new(6)
#     package "gpg"
#     package "pygpgme"

#     file ::File.join(build_user_home, '.gpg_passphrase') do
#       owner node["omnibus"]["build_user"]
#       mode 0600
#       content node["omnibus_sensu"]["gpg_passphrase"]
#       sensitive true
#     end

#     gnupg_tar_path = ::File.join(build_user_home, 'gnupg.tar')

#     aws_s3_file gnupg_tar_path do
#       bucket node["omnibus_sensu"]["publishers"]["s3"]["cache_bucket"]
#       remote_path 'gpg/gnupg.tar'
#       aws_access_key node["omnibus_sensu"]["publishers"]["s3"]["access_key_id"]
#       aws_secret_access_key  node["omnibus_sensu"]["publishers"]["s3"]["secret_access_key"]
#       region node["omnibus_sensu"]["publishers"]["s3"]["region"]
#       owner node["omnibus"]["build_user"]
#       group node["omnibus"]["build_user_group"]
#     end

#     execute 'unpack-gpg-tarball' do
#       command "tar -xvf #{gnupg_tar_path}"
#       cwd '/root'
#     end
#   end
# end

gem_package "ffi-yajl" do
  if windows?
    gem_binary "call C:/omnibus/load-omnibus-toolchain.bat && C:/opscode/omnibus-toolchain/embedded/bin/gem"
  else
    gem_binary "/opt/omnibus-toolchain/bin/gem"
  end
end

directory node["omnibus_sensu"]["project_dir"] do
  user node["omnibus"]["build_user"]
  group node["omnibus"]["build_user_group"]
  recursive true
  action :create
end

project_dir = windows? ? File.join("C:", node["omnibus_sensu"]["project_dir"]) : node["omnibus_sensu"]["project_dir"]

template ::File.join(node["omnibus_sensu"]["project_dir"], "omnibus.rb") do
  source "omnibus.rb.erb"
  sensitive true
  user node["omnibus"]["build_user"] unless windows?
  group node["omnibus"]["build_user_group"] unless windows?
  variables(
    :aws_region => node["omnibus_sensu"]["publishers"]["s3"]["region"],
    :aws_access_key_id => node["omnibus_sensu"]["publishers"]["s3"]["access_key_id"],
    :aws_secret_access_key => node["omnibus_sensu"]["publishers"]["s3"]["secret_access_key"],
    :aws_s3_cache_bucket => node["omnibus_sensu"]["publishers"]["s3"]["cache_bucket"]
  )
end

shared_env = {
  "SENSU_VERSION" => node["omnibus_sensu"]["build_version"],
  "BUILD_NUMBER" => node["omnibus_sensu"]["build_iteration"],
}

case node["platform"]
when "debian"
  # replace omnibus-toolchain tar with system tar as dpkg-deb requires --clamp-mtime now
  if Gem::Version.new(node["platform_version"]) >= Gem::Version.new(9)
    embedded_tar_path = "/opt/omnibus-toolchain/embedded/bin/tar"

    file embedded_tar_path do
      action :delete
    end

    link embedded_tar_path do
      to "/bin/tar"
    end
  end
end

omnibus_build "sensu_plugin_ruby" do
  project_dir node["omnibus_sensu"]["project_dir"]
  log_level :info
  build_user "root" unless windows?
  environment shared_env
  live_stream true
  timeout 7200
end

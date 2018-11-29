name "sensu-install"
default_version "0.1.0"

dependency "ruby"
dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  files_dir = "#{project.files_path}/#{name}"

  gem "install sensu-install" \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      " --no-ri --no-rdoc", env: env

  share_dir = File.join(install_dir, "embedded", "share", "sensu")
  bin_dir = File.join(install_dir, "bin")
  embedded_bin_dir = File.join(install_dir, "embedded", "bin")

  if freebsd?
    etc_dir = "/usr/local/etc"
    usr_bin_dir = "/usr/local/bin"
  elsif mac_os_x?
    etc_dir = "/etc"
    usr_bin_dir = "/usr/local/bin"
  else
    etc_dir = "/etc"
    usr_bin_dir = "/usr/bin"
  end

  # make directories
  mkdir("#{install_dir}/bin")

  # sensu-install (in omnibus bin dir)
  if windows?
    copy("#{files_dir}/sensu-install.bat", "#{bin_dir}/sensu-install")
  else
    copy("#{files_dir}/sensu-install", bin_dir)
    copy("#{files_dir}/sensu-install", "#{usr_bin_dir}/sensu-install")
    command("chmod +x #{bin_dir}/sensu-install")
    command("chmod +x #{usr_bin_dir}/sensu-install")
  end

  project.extra_package_file("#{usr_bin_dir}/sensu-install")
end

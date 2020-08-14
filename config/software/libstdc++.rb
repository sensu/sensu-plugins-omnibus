name "libstdc++"
description "Copy libstdc++"
skip_transitive_dependency_licensing true
default_version "0.0.1"

build do
  path = nil

  # copy libstdc++.so.6 from gcc49 on freebsd <= 9.3
  if freebsd? && (ohai["os_version"].to_i <= 903000) && which("gcc49")
    path = "/usr/local/lib/gcc49/libstdc++.so.6"
  end

  if path
    if File.exist?(path)
      copy path, "#{install_dir}/embedded/lib/"
    else
      raise "Cannot find libstdc++ -- where is your g++ compiler?"
    end
  end
end

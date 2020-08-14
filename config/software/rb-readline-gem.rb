name "rb-readline-gem"
skip_transitive_dependency_licensing true
default_version "0.5.3"

dependency "ruby"
dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem "install rb-readline" \
    " --version '#{version}'" \
    " --no-ri --no-rdoc", env: env
end

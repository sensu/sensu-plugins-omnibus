name "rubysl-readline-gem"
skip_transitive_dependency_licensing true
default_version "2.0.2"

dependency "ruby"
dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem "install rubysl-readline" \
    " --version '#{version}'" \
    " --no-ri --no-rdoc", env: env
end

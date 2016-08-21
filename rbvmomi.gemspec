$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'rbvmomi/version'

Gem::Specification.new do |spec|
  spec.name    = 'rbvmomi'
  spec.summary = 'Ruby interface to the VMware vSphere API'
  spec.version = RbVmomi::VERSION

  spec.authors  = ['Rich Lane', 'Christian Dickmann']
  spec.email    = 'jr@garciaole.com'
  spec.homepage = 'https://github.com/vmware/rbvmomi'

  spec.bindir = 'exe'
  spec.files  = `git ls-files -z`.split("\x0").reject { |f| f.match(/^test\//) }
  spec.executables << 'rbvmomish'
  spec.extensions << 'ext/mkrf_conf.rb'

  spec.add_runtime_dependency('builder', '~> 3.2')
  spec.add_runtime_dependency('json', '~> 1.8')
  spec.add_runtime_dependency('nokogiri', '~> 1.6')
  spec.add_runtime_dependency('trollop', '~> 2.1')

  spec.add_development_dependency('rake', '~> 10.5')
  spec.add_development_dependency('simplecov', '~> 0.12.0')
  spec.add_development_dependency('yard', '~> 0.9.5')

  unless RUBY_VERSION =~ /^1.8/
    spec.add_development_dependency('test-unit', '~> 3.2')
  end

  spec.required_ruby_version = '>= 1.8.7'
end

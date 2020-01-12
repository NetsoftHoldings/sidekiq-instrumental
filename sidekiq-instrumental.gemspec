# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/instrumental/version'

Gem::Specification.new do |spec|
  spec.name = 'sidekiq-instrumental'
  spec.version = Sidekiq::Instrumental::VERSION
  spec.authors = ['Edward Rudd']
  spec.email = ['urkle@outoforder.cc']

  spec.summary = 'Send Sidekiq status into Instrumental after every job'
  spec.homepage = 'https://github.com/NetsoftHoldings/sidekiq-instrumental/'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`
                 .split("\x0")
                 .reject { |f| f.match(%r{^(spec)/}) }
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.test_files = Dir['spec/**/*']

  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'instrumental_agent', '>= 0.13'
  spec.add_runtime_dependency 'sidekiq', '>= 3.5'

  spec.add_development_dependency 'activesupport', '~> 5.0'
  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'timecop', '~> 0.9.1'

  spec.add_development_dependency 'rubocop', '~> 0.79.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.37.1'
end

# frozen_string_literal: true

require_relative 'lib/rate_limit/version'

Gem::Specification.new do |spec|
  spec.name          = 'rate-limit'
  spec.version       = RateLimit::VERSION
  spec.authors       = ['Mohamed Motaweh']
  spec.email         = ['opensource@catawiki.nl']

  spec.summary       = 'A Rate Limiting Gem'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7'

  spec.homepage = 'https://github.com/catawiki/rate-limit'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 5.2', '<= 7.0.7'
  spec.add_dependency 'redis', '>= 3.0.0', '<= 5.1.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end

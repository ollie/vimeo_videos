# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vimeo_videos/version'

Gem::Specification.new do |spec|
  spec.name          = 'vimeo_videos'
  spec.version       = VimeoVideos::VERSION
  spec.authors       = ['Oldrich Vetesnik']
  spec.email         = ['oldrich.vetesnik@gmail.com']
  spec.summary       = %q{Upload videos to Vimeo through V2 API.}
  spec.description   = %q{Simple library for uploading videos through Vimeo V2 API, uses OAuth 1.}
  spec.homepage      = 'https://github.com/ollie/vimeo_videos'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # System
  spec.add_development_dependency 'bundler', '~> 1.6'

  # Test
  spec.add_development_dependency 'rspec',     '~> 2.14'
  spec.add_development_dependency 'webmock',   '~> 1.17'
  spec.add_development_dependency 'simplecov', '~> 0.8'

  # Code style, debugging, docs
  spec.add_development_dependency 'rubocop', '~> 0.20'
  spec.add_development_dependency 'pry',     '~> 0.9'
  spec.add_development_dependency 'yard',    '~> 0.8'
  spec.add_development_dependency 'rake',    '~> 10.3'

  # Networking
  spec.add_runtime_dependency 'typhoeus',     '~> 0.6' # Fast networking
  spec.add_runtime_dependency 'oj',           '~> 2.8' # Fast JSON parsing/dumping
  spec.add_runtime_dependency 'simple_oauth', '~> 0.2' # OAuth headers generator
end

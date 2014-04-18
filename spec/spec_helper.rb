require 'bundler/setup'

require 'simplecov'
require 'webmock' # Disable all HTTP access

# Coverage tool, needs to be started as soon as possible
SimpleCov.start do
  add_filter '/spec/' # Ignore spec directory
end

require 'request_stubs'
require 'vimeo_videos'

EXAMPLE_VIDEO = File.expand_path( '../../example/example-video.mp4', __FILE__ )

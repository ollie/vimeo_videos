require 'bundler/setup'

require 'simplecov'
require 'webmock' # Disable all HTTP access
require 'oj'

# Coverage tool, needs to be started as soon as possible
SimpleCov.start do
  add_filter '/spec/' # Ignore spec directory
end

require 'vimeo_videos'
require 'request_stubs'

EXAMPLE_VIDEO = File.expand_path( '../../example/example-video.mp4', __FILE__ )

# RSpec.configure do |config|
#   config.after(:each) do
#     WebMock.reset!
#   end
# end

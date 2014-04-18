require 'bundler'
Bundler.require

require File.expand_path( '../../lib/vimeo_videos', __FILE__ )
require 'yaml'

config = YAML.load( File.read('config.yml') )
client = VimeoVideos::Client.new(
  client_id:           config['client_id'],
  client_secret:       config['client_secret'],
  access_token:        config['access_token'],
  access_token_secret: config['access_token_secret'],
)

begin
  file_path = File.expand_path( '../example-video.mp4', __FILE__ )
  video_id  = client.upload(file_path)
  puts video_id
  # binding.pry
rescue VimeoVideos::APIException => e
  puts "Oh noes, something broke: #{ e }"
end

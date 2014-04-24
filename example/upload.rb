# To run this example, +cd+ into this directory.

require 'bundler'
Bundler.require

require '../lib/vimeo_videos'
require 'yaml'

config = YAML.load( File.read('config.yml') )
client = VimeoVideos::Client.new(
  client_id:           config['client_id'],
  client_secret:       config['client_secret'],
  access_token:        config['access_token'],
  access_token_secret: config['access_token_secret'],
)

begin
  # video_id = client.upload('example-video.mp4') # Default chunk_temp_dir and chunk_size
  video_id = client.upload('example-video.mp4', temp_dir: '../tmp', chunk_size: 100_000)
  puts video_id
rescue VimeoVideos::BaseError => e
  puts "Oh noes, something broke: #{ e }"
end

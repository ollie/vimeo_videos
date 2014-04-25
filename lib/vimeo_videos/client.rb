require 'vimeo_videos/client/credentials'

module VimeoVideos
  # Top-level manager that provides the publick interface.
  # See example directory.
  class Client
    include VimeoVideos::Client::Credentials

    # A client will upload videos without doing the user-auth process,
    # that's why it needs the access token and secret.
    #
    # @param credentials [Hash]
    #   :client_id
    #   :client_secret
    #   :access_token
    #   :access_token_secret
    def initialize(credentials = {})
      self.client_id           = credentials[:client_id]
      self.client_secret       = credentials[:client_secret]
      self.access_token        = credentials[:access_token]
      self.access_token_secret = credentials[:access_token_secret]
    end

    # OAuth options for SimpleOauth::Header.
    #
    # @return [Hash] A hash ready to be passed to SimpleOauth::Header
    def oauth_options
      {
        consumer_key:    client_id,
        consumer_secret: client_secret,
        token:           access_token,
        token_secret:    access_token_secret
      }
    end

    # Upload a file to Vimeo.
    #
    # @param file_path [String] path to the video file
    # @param options   [Hash]
    #   :temp_dir   - video will be chunked in this directory, defaults to 'tmp'
    #   :chunk_size - defaults to 2 MB
    # @return [String] video_id
    def upload(file_path, options = {})
      Upload.new(file_path, self, options).upload!
    end

    # Make a Vimeo API request.
    def request(*args)
      Request.new(self).request(*args)
    end

    # Make a upload requests to Vimeo.
    def upload_request(*args)
      UploadRequest.new(self).request(*args)
    end
  end
end

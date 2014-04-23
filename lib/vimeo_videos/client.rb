require 'vimeo_videos/client/defaults'
require 'vimeo_videos/client/credentials'

module VimeoVideos
  # Does the API calls.
  class Client
    include VimeoVideos::Client::Defaults
    include VimeoVideos::Client::Credentials

    # The V2 URL.
    API_URL = 'https://vimeo.com/api/rest/v2'

    # Let the API know we want JSON.
    VERSION_STRING = 'application/vnd.vimeo.*+json; version=2.0'

    # And let it know that it's us.
    USER_AGENT = 'VimeoVideos (https://github.com/ollie/vimeo_videos)'

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

    # Upload a file to Vimeo.
    #
    # @param file_path [String] path to the video file
    # @return video_id
    def upload(file_path)
      Upload.new(file_path, self).upload!
    end

    # Make an API call.
    #
    # @param method         [String] eg 'vimeo.videos.upload.getQuota'
    # @param params         [Hash]   HTTP parameters
    # @param request_method [String] :get, :post, :put, :delete
    def request(method, params = {}, request_method = :get, api_url = API_URL)
      # oauth = {
      #   consumer_key: client_id,
      #   token:        access_token,
      # }

      # params[:method] = method

      # header = SimpleOAuth::Header.new(
      #   request_method,
      #   api_url,
      #   params,
      #   oauth
      # )

      # binding.pry
    end
  end
end

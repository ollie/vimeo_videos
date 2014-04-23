require 'vimeo_videos/client/defaults'
require 'vimeo_videos/client/credentials'

module VimeoVideos
  # Does the API calls.
  class Client
    include VimeoVideos::Client::Defaults
    include VimeoVideos::Client::Credentials

    # The V2 URL.
    API_URL = 'https://vimeo.com/api/rest/v2'

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
    # @param request_method [Symbol] :get, :post, :put, :delete
    # @param api_url        [String] root API URL
    def request(api_method, params = {}, request_method = :get, api_url = API_URL)
      request  = new_request(api_method, params, request_method, api_url)
      response = get_response(request)
      response
    end

    def new_request(api_method, params, request_method, api_url)
      params[:method] = api_method
      params[:format] = 'json'

      header = new_header(params, request_method, api_url)

      Typhoeus::Request.new(
        header.url,
        method: header.method.downcase.to_sym,
        params: header.params,
        headers: {
          'User-Agent'    => USER_AGENT,
          'Authorization' => header.to_s
        }
      )
    end

    def new_header(params, request_method, api_url)
      header = SimpleOAuth::Header.new(
        request_method,
        api_url,
        params,
        oauth_options
      )
      header
    end

    def oauth_options
      options = {
        consumer_key:    client_id,
        consumer_secret: client_secret,
        token:           access_token,
        token_secret:    access_token_secret
      }
      options
    end

    def get_response(request)
      response    = request.run
      raw_body    = response.body
      parsed_body = Oj.load(raw_body, OJ_OPTIONS)

      fail ApiError, "#{ parsed_body.inspect }" if parsed_body[:stat] != 'ok'

      parsed_body
    end
  end
end

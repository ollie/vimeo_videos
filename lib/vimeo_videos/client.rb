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
    # @return [String] video_id
    def upload(file_path)
      Upload.new(file_path, self).upload!
    end

    # Make an API call.
    #
    # @param api_method     [String] eg 'vimeo.videos.upload.getQuota'
    # @param params         [Hash]   HTTP parameters
    # @param request_method [Symbol] :get, :post, :put, :delete
    # @param api_url        [String] root API URL
    def request(api_method, params = {}, request_method = :get, api_url = API_URL)
      request  = new_request(api_method, params, request_method, api_url)
      response = get_response(request)
      response
    end

    protected

    # Creates a new API request ready to be run.
    #
    # @param api_method     [String] eg 'vimeo.videos.upload.getQuota'
    # @param params         [Hash]   HTTP parameters
    # @param request_method [Symbol] :get, :post, :put, :delete
    # @param api_url        [String] root API URL
    # @return [Typhoeus::Request]
    def new_request(api_method, params, request_method, api_url)
      params.merge!(method: api_method, format: 'json')
      header = new_header(params, request_method, api_url)

      typhoeus_request(header, params, request_method, api_url)
    end

    # Create a Typhoeus::Request.
    #
    # @param header         [SimpleOAuth::Header] OAuth headers
    # @param params         [Hash]   HTTP parameters
    # @param request_method [Symbol] :get, :post, :put, :delete
    # @param api_url        [String] root API URL
    # @return [Typhoeus::Request]
    def typhoeus_request(header, params, request_method, api_url)
      Typhoeus::Request.new(
        header.url,
        method: request_method,
        params: header.params,
        headers: {
          'User-Agent'    => USER_AGENT,
          'Authorization' => header.to_s
        }
      )
    end

    # Constructs a new SimpleOAuth::Header instance
    # ready to be used for Typhoeus request.
    #
    # @param params         [Hash]   HTTP parameters
    # @param request_method [Symbol] :get, :post, :put, :delete
    # @param api_url        [String] root API URL
    # @return [SimpleOAuth::Header]
    def new_header(params, request_method, api_url)
      SimpleOAuth::Header.new(
        request_method,
        api_url,
        params,
        oauth_options
      )
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

    # Takes a Typhoeus request, runs it and runs the response
    # through Oj to get a Hash.
    #
    # @param request [Typhoeus::Request] request to run
    # @return [Hash] parsed response
    def get_response(request)
      response    = request.run
      raw_body    = response.body
      parsed_body = Oj.load(raw_body, OJ_OPTIONS)

      if parsed_body[:stat] != 'ok'
        fail ClientError, "#{ parsed_body.inspect }"
      end

      parsed_body
    end
  end
end

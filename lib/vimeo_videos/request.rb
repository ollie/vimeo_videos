module VimeoVideos
  # Useful for simple requests.
  class Request < BaseRequest
    # @return [Hash] HTTP parameters
    attr_accessor :params

    # @return [Symbol] :get, :post, :put, :delete
    attr_accessor :request_method

    # @return [SimpleOAuth::Header] OAuth headers
    attr_accessor :header

    # @return [Typhoeus::Request] request to run
    attr_accessor :typhoeus_request

    # @return [Typhoeus::Response] response of the request
    attr_accessor :response

    # @return [Hash] Oj-parsed response.
    attr_accessor :body

    # Make a general Vimeo API request.
    #
    # @param api_method     [String] eg 'vimeo.videos.upload.getQuota'
    # @param params         [Hash]   HTTP parameters
    # @param request_method [Symbol] :get, :post, :put, :delete
    def request(api_method, params = {}, request_method = :get)
      self.params           = params.merge(method: api_method, format: 'json')
      self.request_method   = request_method
      self.header           = new_header
      self.typhoeus_request = new_typhoeus_request
      self.response         = typhoeus_request.run
      self.body             = Oj.load(response.body, OJ_OPTIONS)
      check_response!
      body
    end

    # Constructs a new SimpleOAuth::Header instance
    # ready to be used for Typhoeus request.
    def new_header
      SimpleOAuth::Header.new(
        request_method,
        API_URL,
        params,
        client.oauth_options
      )
    end

    # Create a Typhoeus::Request.
    def new_typhoeus_request
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

    # Check if the response was successful.
    def check_response!
      body[:stat] == 'ok' || fail(ClientError, "#{ body.inspect }")
    end
  end
end

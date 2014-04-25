module VimeoVideos
  # Useful for simple requests.
  class Request < BaseRequest
    # Make a general Vimeo API request.
    #
    # @param api_method     [String] eg 'vimeo.videos.upload.getQuota'
    # @param params         [Hash]   HTTP parameters
    # @param request_method [Symbol] :get, :post, :put, :delete
    def request(api_method, params = {}, request_method = :get)
      params.merge!(method: api_method, format: 'json')

      header = SimpleOAuth::Header.new(
        request_method,
        API_URL,
        params,
        client.oauth_options
      )

      request = Typhoeus::Request.new(
        header.url,
        method: request_method,
        params: header.params,
        headers: {
          'User-Agent'    => USER_AGENT,
          'Authorization' => header.to_s
        }
      )

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

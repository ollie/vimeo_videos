module VimeoVideos
  # Does the API calls.
  class Client
    OJ_OPTIONS = {
      mode:             :compat,     # Converts values with to_hash or to_json
      symbol_keys:      true,        # Symbol keys to string keys
      time_format:      :xmlschema,  # ISO8061 format
      second_precision: 0,           # No include milliseconds
    }

    API_URL           = 'https://vimeo.com/api/rest/v2'
    REQUEST_TOKEN_URL = 'https://vimeo.com/oauth/request_token'
    AUTHORIZE_URL     = 'https://vimeo.com/oauth/authorize'
    ACCESS_TOKEN_URL  = 'https://vimeo.com/oauth/access_token'

    attr_reader :client_id
    attr_reader :client_secret
    attr_reader :access_token
    attr_reader :access_token_secret

    # Create a new client. Requires a client id + secret
    # as well as access token + secret.
    #
    # @param options [Hash]
    #   :client_id
    #   :client_secret
    #   :access_token
    #   :access_token_secret
    def initialize(options = {})
      self.client_id           = options[:client_id]
      self.client_secret       = options[:client_secret]
      self.access_token        = options[:access_token]
      self.access_token_secret = options[:access_token_secret]
    end

    protected

    def client_id=(value)
      if value.nil? || value.empty?
        fail(ArgumentError, "Invalid client_id: #{ value }")
      end

      @client_id = value
    end

    def client_secret=(value)
      if value.nil? || value.empty?
        fail(ArgumentError, "Invalid client_secret: #{ value }")
      end

      @client_secret = value
    end

    def access_token=(value)
      if value.nil? || value.empty?
        fail(ArgumentError, "Invalid access_token: #{ value }")
      end

      @access_token = value
    end

    def access_token_secret=(value)
      if value.nil? || value.empty?
        fail(ArgumentError, "Invalid access_token_secret: #{ value }")
      end

      @access_token_secret = value
    end
  end
end

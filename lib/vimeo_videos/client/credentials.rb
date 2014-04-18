module VimeoVideos
  class Client
    # Abstracted OAuth credentials.
    module Credentials
      attr_reader :client_id
      attr_reader :client_secret
      attr_reader :access_token
      attr_reader :access_token_secret

      # Set consumer key.
      def client_id=(value)
        if value.nil? || value.empty?
          fail(ArgumentError, "Invalid client_id: #{ value }")
        end

        @client_id = value
      end

      # Set consumer secret.
      def client_secret=(value)
        if value.nil? || value.empty?
          fail(ArgumentError, "Invalid client_secret: #{ value }")
        end

        @client_secret = value
      end

      # Set user access token.
      def access_token=(value)
        if value.nil? || value.empty?
          fail(ArgumentError, "Invalid access_token: #{ value }")
        end

        @access_token = value
      end

      # Set user access token secret.
      def access_token_secret=(value)
        if value.nil? || value.empty?
          fail(ArgumentError, "Invalid access_token_secret: #{ value }")
        end

        @access_token_secret = value
      end
    end
  end
end

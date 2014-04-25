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
    # @param options   [Hash]   :chunk_temp_dir, :chunk_size
    # @return [String] video_id
    def upload(file_path, options = {})
      Upload.new(file_path, self, options).upload!
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

    # Run through the chunks and upload them.
    #
    # @param ticket [Hash]        Upload ticket :id, :endpoint_secure, :max_file_size
    # @param chunks [Array<Hash>] Hash is :number, :file, :size
    def upload_chunks(ticket, chunks)
      hydra = Typhoeus::Hydra.new

      chunks.each do |chunk|
        request = chunk_upload_request(ticket, chunk)
        hydra.queue(request)
      end

      hydra.run
    end

    # Send a file chunk to Vimeo.
    #
    # @param ticket [Hash] Upload ticket :id, :endpoint_secure, :max_file_size
    # @param chunk  [Hash] :number, :file, :size
    def chunk_upload_request(ticket, chunk)
      params = {
        ticket_id: ticket[:id],
        chunk_id:  chunk[:number].to_s
      }

      header = SimpleOAuth::Header.new(
        :post,
        ticket[:endpoint_secure],
        params,
        oauth_options
      )

      body = header.params.merge(
        file_data: File.open(chunk[:file], 'rb')
      )

      request = Typhoeus::Request.new(
        header.url,
        method: :post,
        params: header.params,
        body:   body,
        headers: {
          'User-Agent'    => USER_AGENT,
          'Authorization' => header.to_s
        }
      )

      request.on_complete do |response|
        unless response.success?
          fail ChunkUploadFailed, response.body.strip
        end
      end

      request
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

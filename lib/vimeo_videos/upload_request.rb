module VimeoVideos
  # Complicated upload request.
  class UploadRequest < BaseRequest
    # Run through the chunks and upload them in parallel.
    #
    # @param ticket [Hash]
    #   :id
    #   :endpoint_secure
    #   :max_file_size
    # @param chunks [Array<Hash>] Chunk is:
    #   :number
    #   :file
    #   :size
    def request(ticket, chunks)
      hydra = Typhoeus::Hydra.new

      chunks.each do |chunk|
        request = upload_request(ticket, chunk)
        hydra.queue(request)
      end

      hydra.run
    end

    protected

    # Make a Typhoeus::Request for chunk upload.
    #
    # @param ticket [Hash]
    #   :id
    #   :endpoint_secure
    #   :max_file_size
    # @param chunk [Hash]
    #   :number
    #   :file
    #   :size
    def upload_request(ticket, chunk)
      params = {
        ticket_id: ticket[:id],
        chunk_id:  chunk[:number].to_s
      }

      header = SimpleOAuth::Header.new(
        :post,
        ticket[:endpoint_secure],
        params,
        client.oauth_options
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
        response.success? || fail(ChunkUploadFailed, response.body.strip)
      end

      request
    end
  end
end

require 'spec_helper'

describe VimeoVideos::Upload do
  # context 'upload! with one chunk' do
  #   before do
  #     client = VimeoVideos::Client.new(
  #       client_id:           'client_id',
  #       client_secret:       'client_secret',
  #       access_token:        'access_token',
  #       access_token_secret: 'access_token_secret'
  #     )

  #     @upload = VimeoVideos::Upload.new(EXAMPLE_VIDEO, client)
  #   end

  #   it 'uploads' do
  #     expect { @upload.upload! }.to_not raise_error
  #   end
  # end

  context 'upload! with multiple chunks' do
    before do
      verify_chunks_response = {
        generated_in: '3.5520',
        stat:         'ok',
        ticket: {
          id: 'efb8545e8776801df481f4cbc234ecdf',
          chunks: {
            chunk: [
              {
                id:   '0',
                size: '100000'
              },
              {
                id:   '1',
                size: '100000'
              },
              {
                id:   '2',
                size: '100000'
              },
              {
                id:   '3',
                size: '83631'
              }
            ]
          }
        }
      }

      @request_stub = WebMock.stub_request(
          :get,
          'https://vimeo.com/api/rest/v2?format=json&method=vimeo.videos.upload.verifyChunks' \
          '&ticket_id=efb8545e8776801df481f4cbc234ecdf')
        .with(
          headers: {
            'Authorization' => /oauth_token="access_token"/
          }
        ).to_return(
          status: 200,
          body:   Oj.dump(verify_chunks_response, VimeoVideos::BaseRequest::OJ_OPTIONS)
        )

      client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )

      @upload = VimeoVideos::Upload.new(EXAMPLE_VIDEO, client, chunk_size: 100_000)
    end

    after do
      WebMock.remove_request_stub(@request_stub)
    end

    it 'uploads' do
      expect { @upload.upload! }.to_not raise_error
    end
  end
end

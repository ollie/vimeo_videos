require 'spec_helper'

describe VimeoVideos::Client do
  context 'Valid client' do
    before do
      @client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )
    end

    it 'has client_id' do
      expect(@client.client_id).to eq('client_id')
    end

    it 'has client_secret' do
      expect(@client.client_secret).to eq('client_secret')
    end

    it 'has access_token' do
      expect(@client.access_token).to eq('access_token')
    end

    it 'has access_token_secret' do
      expect(@client.access_token_secret).to eq('access_token_secret')
    end
  end

  context 'Arguments validation' do
    it 'raises an error with empty credentials' do
      expect do
        VimeoVideos::Client.new {}
      end.to raise_error(ArgumentError)
    end

    it 'raises an error with missing client_id' do
      expect do
        VimeoVideos::Client.new(
          # client_id:           'client_id',
          client_secret:       'client_secret',
          access_token:        'access_token',
          access_token_secret: 'access_token_secret'
        )
      end.to raise_error(ArgumentError)
    end

    it 'raises an error with empty client_id' do
      expect do
        VimeoVideos::Client.new(
          client_id:           '',
          client_secret:       'client_secret',
          access_token:        'access_token',
          access_token_secret: 'access_token_secret'
        )
      end.to raise_error(ArgumentError)
    end

    it 'raises an error with missing client_secret' do
      expect do
        VimeoVideos::Client.new(
          client_id:           'client_id',
          # client_secret:       'client_secret',
          access_token:        'access_token',
          access_token_secret: 'access_token_secret'
        )
      end.to raise_error(ArgumentError)
    end

    it 'raises an error with missing access_token' do
      expect do
        VimeoVideos::Client.new(
          client_id:           'client_id',
          client_secret:       'client_secret',
          # access_token:        'access_token',
          access_token_secret: 'access_token_secret'
        )
      end.to raise_error(ArgumentError)
    end

    it 'raises an error with missing access_token_secret' do
      expect do
        VimeoVideos::Client.new(
          client_id:           'client_id',
          client_secret:       'client_secret',
          access_token:        'access_token',
          # access_token_secret: 'access_token_secret'
        )
      end.to raise_error(ArgumentError)
    end
  end

  context 'Successful API request' do
    before do
      client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )

      @response = client.request('vimeo.videos.upload.getQuota')
    end

    it 'returns quota hash' do
      expect(@response).to eq(SUCCESSFUL_QUOTA_RESPONSE)
    end
  end

  context 'Invalid signature' do
    before do
      @client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'signature_error',
        access_token_secret: 'access_token_secret'
      )
    end

    it 'raises an error' do
      expect do
        @client.request('vimeo.videos.upload.getQuota')
      end.to raise_error(VimeoVideos::RequestError)
    end
  end

  context 'Upload' do
    before do
      @client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )
    end

    it 'fails with invalid file' do
      File.stub(:exist?) { false }
      expect { @client.upload('not_here.mp4') }.to raise_error(ArgumentError)
    end

    it 'uploads' do
      expect { @client.upload(EXAMPLE_VIDEO) }.to_not raise_error
    end
  end
end

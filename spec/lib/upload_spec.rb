require 'spec_helper'

describe VimeoVideos::Upload do
  context 'Arguments validation' do
    it 'raises an error with empty file_path' do
      expect do
        VimeoVideos::Upload.new '', 'dummy'
      end.to raise_error(ArgumentError)
    end

    it 'raises an error when file does not exist' do
      expect do
        File.stub(:file?) { false }
        VimeoVideos::Upload.new 'not_here.mp4', 'dummy'
      end.to raise_error(ArgumentError)
    end

    it 'raises an error with empty client' do
      expect do
        File.stub(:file?)    { true }
        File.stub(:basename) { 'here.mp4' }
        File.stub(:size)     { 10 }
        VimeoVideos::Upload.new 'dummy', nil
      end.to raise_error(ArgumentError)
    end
  end

  context 'Valid imaginary file' do
    before do
      File.stub(:file?)    { true }
      File.stub(:basename) { 'here.mp4' }
      File.stub(:size)     { 10 }

      @upload = VimeoVideos::Upload.new('here.mp4', 'dummy')
    end

    it 'sets file_path' do
      expect(@upload.file_path).to eq('here.mp4')
    end

    it 'sets client' do
      expect(@upload.client).to eq('dummy')
    end

    it 'sets file_name' do
      expect(@upload.file_name).to eq('here.mp4')
    end

    it 'sets file_size' do
      expect(@upload.file_size).to eq(10)
    end
  end

  context 'Real file' do
    before do
      client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )

      @upload = VimeoVideos::Upload.new(EXAMPLE_VIDEO, client)
    end

    it 'sets file_path' do
      expect(@upload.file_path).to eq(EXAMPLE_VIDEO)
    end

    it 'sets client' do
      expect(@upload.client).to be_kind_of(VimeoVideos::Client)
    end

    it 'sets file_name' do
      expect(@upload.file_name).to eq('example-video.mp4')
    end

    it 'sets file_size' do
      expect(@upload.file_size).to eq(383_631)
    end

    it 'upload!' do
      expect { @upload.upload! }.to_not raise_error
    end
  end
end

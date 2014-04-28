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

    it 'raises an error with empty temp_dir' do
      expect do
        File.stub(:file?)    { true }
        File.stub(:basename) { 'here.mp4' }
        File.stub(:size)     { 10 }
        VimeoVideos::Upload.new 'here.mp4', 'dummy', temp_dir: ''
      end.to raise_error(ArgumentError)
    end

    it 'raises an error when temp_dir does not exist' do
      expect do
        File.stub(:file?)    { true }
        File.stub(:basename) { 'here.mp4' }
        File.stub(:size)     { 10 }
        VimeoVideos::Upload.new 'here.mp4', 'dummy', temp_dir: 'not_here'
      end.to raise_error(ArgumentError)
    end

    it 'raises an error when temp_dir is not writable' do
      expect do
        File.stub(:file?)      { true }
        File.stub(:basename)   { 'here.mp4' }
        File.stub(:size)       { 10 }
        File.stub(:directory?) { true }
        File.stub(:writable?)  { false }
        VimeoVideos::Upload.new 'here.mp4', 'dummy', temp_dir: 'not_writable'
      end.to raise_error(ArgumentError)
    end

    it 'raises an error when chunk_size is not a number' do
      expect do
        File.stub(:file?)      { true }
        File.stub(:basename)   { 'here.mp4' }
        File.stub(:size)       { 10 }
        VimeoVideos::Upload.new 'here.mp4', 'dummy', chunk_size: ':P'
      end.to raise_error(ArgumentError)
    end

    it 'raises an error when chunk_size is negative' do
      expect do
        File.stub(:file?)      { true }
        File.stub(:basename)   { 'here.mp4' }
        File.stub(:size)       { 10 }
        VimeoVideos::Upload.new 'here.mp4', 'dummy', chunk_size: -10
      end.to raise_error(ArgumentError)
    end
  end

  context 'Valid imaginary file' do
    before do
      File.stub(:file?)    { true }
      File.stub(:basename) { 'here.mp4' }
      File.stub(:size)     { 1_000_000 }

      @upload = VimeoVideos::Upload.new('here.mp4', 'dummy', chunk_size: 300_000)
    end

    it 'sets file_path' do
      expect(@upload.file_path.to_s).to eq('here.mp4')
    end

    it 'sets file_name' do
      expect(@upload.file_name).to eq('here.mp4')
    end

    it 'sets file_size' do
      expect(@upload.file_size).to eq(1_000_000)
    end

    it 'sets client' do
      expect(@upload.client).to eq('dummy')
    end

    it 'sets temp_dir' do
      expect(@upload.temp_dir.to_s).to eq('tmp')
    end

    it 'sets chunk_size' do
      expect(@upload.chunk_size).to eq(300_000)
    end

    it 'sets chunks' do
      expect(@upload.chunks).to eq([])
    end

    it 'sets number_of_chunks' do
      expect(@upload.number_of_chunks).to eq(4)
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
      expect(@upload.file_path.to_s).to eq(EXAMPLE_VIDEO)
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
  end
end

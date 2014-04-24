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

  context 'upload!' do
    before do
      client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )

      @upload = VimeoVideos::Upload.new(EXAMPLE_VIDEO, client)
    end

    it 'uploads' do
      expect { @upload.upload! }.to_not raise_error
    end
  end

  context 'check_free_space!' do
    before do
      client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )

      @upload = VimeoVideos::Upload.new(EXAMPLE_VIDEO, client)
    end

    it 'not enough free space raises error' do
      @upload.stub(:file_size) { 22_000_000_000 }

      expect do
        @upload.check_free_space!
      end.to raise_error(VimeoVideos::NoEnoughFreeSpaceError)
    end
  end

  context 'load_upload_ticket!' do
    before do
      client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )

      @upload = VimeoVideos::Upload.new(EXAMPLE_VIDEO, client)
      @upload.load_upload_ticket!
    end

    it 'has ticket id' do
      expect(@upload.ticket[:id]).to eq('efb8545e8776801df481f4cbc234ecdf')
    end

    it 'has ticket endpoint_secure' do
      expect(@upload.ticket[:endpoint_secure]).to eq(
        'https://1511493072.cloud.vimeo.com/upload_multi?ticket_id=efb8545e8776801df481f4cbc234ecdf'
      )
    end

    it 'has ticket max_file_size' do
      expect(@upload.ticket[:max_file_size]).to eq(21_474_836_480)
    end
  end

  context 'check_upload_size!' do
    before do
      client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )

      @upload = VimeoVideos::Upload.new(EXAMPLE_VIDEO, client)
    end

    it 'not enough free space raises error' do
      @upload.stub(:file_size) { 22_000_000_000 }
      @upload.stub(:ticket)    { { max_file_size: 10_000_000_000 } }

      expect do
        @upload.check_upload_size!
      end.to raise_error(VimeoVideos::MaxFileSizeExceededError)
    end
  end

  context 'create_chunk_temp_dir!' do
    before do
      client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )

      @upload = VimeoVideos::Upload.new(EXAMPLE_VIDEO, client)
    end

    it 'creates and deletes a dir' do
      dir_size = Dir['tmp/*'].size

      expect(Dir['tmp/*'].size).to eq(dir_size)
      @upload.create_chunk_temp_dir!
      expect(Dir['tmp/*'].size).to eq(dir_size + 1)
      @upload.delete_chunk_temp_dir!
      expect(Dir['tmp/*'].size).to eq(dir_size)
    end

    it 'does not raise an error when dir does not exist' do
      expect { @upload.delete_chunk_temp_dir! }.to_not raise_error
    end
  end
end

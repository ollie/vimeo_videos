require 'spec_helper'

describe VimeoVideos::Upload do
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

  context 'split_file_into_chunks!' do
    before do
      client = VimeoVideos::Client.new(
        client_id:           'client_id',
        client_secret:       'client_secret',
        access_token:        'access_token',
        access_token_secret: 'access_token_secret'
      )

      @upload = VimeoVideos::Upload.new(EXAMPLE_VIDEO, client, chunk_size: 100_000)
      @upload.create_chunk_temp_dir!
    end

    after do
      @upload.delete_chunk_temp_dir!
    end

    it 'creates chunks' do
      files_count = Dir[ @upload.chunk_temp_dir.join('*') ].size
      expect(files_count).to eq(0)

      @upload.split_file_into_chunks!

      files_count = Dir[ @upload.chunk_temp_dir.join('*') ].size
      expect(files_count).to eq(4)
    end
  end
end

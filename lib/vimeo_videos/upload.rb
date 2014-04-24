module VimeoVideos
  # Does the uploading and upload-talking.
  class Upload
    attr_reader :file_path, :client, :file_name, :file_size

    # @param file_path [String] video file path
    # @param client    [Client] the client is used to call the API
    def initialize(file_path, client)
      self.file_path = file_path
      self.client    = client
      load_file_name
      load_file_size
    end

    # Set path to the video file.
    def file_path=(value)
      if value.nil? || value.empty?
        fail(ArgumentError, "Invalid file_path: #{ value }")
      end

      fail(ArgumentError, 'File seems to be missing') unless File.file?(value)

      @file_path = value
    end

    # Set client.
    def client=(value)
      fail(ArgumentError, "Invalid file_path: #{ value }") unless value
      @client = value
    end

    # Reads the name of the video file and saves it.
    def load_file_name
      @file_name = File.basename(file_path)
    end

    # Reads the size of the video file and saves it.
    def load_file_size
      @file_size = File.size(file_path)
    end

    # Do the checking, uploading.
    def upload!
      check_free_space!
      # get_upload_ticket!
      # check_upload_size!
      # split_file_into_chunks!
      # upload_chunks!
      # verify_chunks!
      # complete_upload!
      # delete_chunks!
      # delete_video!
    end

    # We need to check if there is enough space in the user's quota.
    def check_free_space!
      response   = client.request('vimeo.videos.upload.getQuota')
      free_space = response[:user][:upload_space][:free].to_i

      if file_size > free_space
        message = "Video size: #{ file_size }, free space: #{ free_space }"
        fail NoEnoughFreeSpaceError, message
      end
    end
  end
end

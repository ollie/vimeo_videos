module VimeoVideos
  # Does the uploading and upload-talking.
  class Upload
    attr_reader :file_path, :client, :file_name, :file_size

    # [Hash] :id
    #        :endpoint_secure
    #        :max_file_size
    attr_accessor :ticket

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
      load_upload_ticket!
      check_upload_size!
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

    # Requests a new upload ticket and stores it in @ticket.
    def load_upload_ticket!
      response    = client.request('vimeo.videos.upload.getTicket')
      ticket      = response[:ticket]

      self.ticket = {
        id:              ticket[:id],
        endpoint_secure: ticket[:endpoint_secure],
        max_file_size:   ticket[:max_file_size].to_i
      }
    end

    # If a file is larger than an upload ticket allows, we are done.
    def check_upload_size!
      if file_size > ticket[:max_file_size]
        message = "Video size: #{ file_size }, ticket size: #{ ticket[:max_file_size] }"
        fail MaxFileSizeExceededError, message
      end
    end
  end
end

module VimeoVideos
  # Does the uploading and upload-talking.
  class Upload
    # @return [Pathname] path to the video file
    attr_reader :file_path

    # @return [Client] Client instance
    attr_reader :client

    # @return [String] name of the video file
    attr_accessor :file_name

    # @return [Fixnum] size of the video file
    attr_accessor :file_size

    # @return [Pathname] path to dir where chunks dirs will be stored, defaults to 'tmp'
    attr_reader :temp_dir

    # @return [Pathname] path to dir where video chunks will be stored, defaults to 'tmp'
    attr_accessor :chunk_temp_dir

    # @return [Fixnum] chunk a video by chunk_size bytes, defaults to 2 MB
    attr_reader :chunk_size

    # @return [Array] array of chunks (video split into pieces)
    attr_accessor :chunks

    # @return [Fixnum] to how many pieces split the video into
    attr_accessor :number_of_chunks

    # @return [Hash] :id, :endpoint_secure, :max_file_size
    attr_accessor :ticket

    # @param file_path [String] video file path
    # @param client    [Client] the client is used to call the API
    # @param options   [Hash]   :temp_dir, :chunk_size
    def initialize(file_path, client, options = {})
      self.file_path        = file_path
      self.file_name        = File.basename(file_path)
      self.file_size        = File.size(file_path)
      self.client           = client
      self.temp_dir         = options[:temp_dir] || 'tmp'
      self.chunk_size       = options[:chunk_size]     || 2_097_152 # 2 MB
      self.chunks           = []
      self.number_of_chunks = (file_size.to_f / chunk_size).ceil
    end

    # @param value [String] video file path
    def file_path=(value)
      if value.nil? || value.empty?
        fail(ArgumentError, 'file_path cannot be empty')
      end

      fail(ArgumentError, 'File seems to be missing') unless File.file?(value)

      @file_path = Pathname.new(value)
    end

    # @param value [Client] the client is used to call the API
    def client=(value)
      fail(ArgumentError, 'client cannot be empty') unless value
      @client = value
    end

    # @param value [String] path to dir where chunks dirs will be stored
    def temp_dir=(value)
      if value.nil? || value.empty?
        fail(ArgumentError, "Invalid temp_dir: #{ value }")
      end

      fail(ArgumentError, "#{ value } is not a directory") unless File.directory?(value)
      fail(ArgumentError, "#{ value } is not writable")    unless File.writable?(value)

      @temp_dir = Pathname.new(value)
    end

    # @param value [Fixnum] chunk a video by chunk_size bytes
    def chunk_size=(value)
      if !value.is_a?(Fixnum) || value < 0
        fail ArgumentError, 'chunk_size must be a fixnum > 0'
      end

      @chunk_size = value
    end

    # Do the checking, uploading.
    def upload!
      check_free_space!
      load_upload_ticket!
      check_upload_size!
      create_chunk_temp_dir!
      split_file_into_chunks!
      # upload_chunks!
      # verify_chunks!
      # complete_upload!
    ensure
      delete_chunks!
      delete_chunk_temp_dir!
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

    # Creates a temporary dir in @temp_dir
    def create_chunk_temp_dir!
      timestamp           = Time.now.strftime('%Y%m%d%H%M%S')
      self.chunk_temp_dir = temp_dir.join(timestamp)
      Dir.mkdir(chunk_temp_dir) unless chunk_temp_dir.exist?
    end

    # Split the video file into multiple pieces to speedup upload.
    def split_file_into_chunks!
      source_file = File.open(file_path, 'rb')

      (1..number_of_chunks).each do |chunk_number|
        chunk = create_chunk(chunk_number, source_file)
        chunks << chunk
      end
    end

    # Read a part of video file and save it into a chunk file.
    #
    # @param chunk_number [Fixnum] chunk_number
    # @param source_file  [File]   the whole video file
    def create_chunk(chunk_number, source_file)
      chunk_name = "#{ file_name }.#{ chunk_number }"
      chunk_file = chunk_temp_dir.join(chunk_name)

      File.open(chunk_file, 'wb') do |f|
        f << source_file.read(chunk_size)
      end

      chunk_info = {
        file: chunk_file,
        size: File.size(chunk_file)
      }

      chunk_info
    end

    # Goes through each chunk and deletes it.
    def delete_chunks!
      chunks.each do |chunk|
        next unless chunk[:file].exist?
        chunk[:file].delete
      end
    end

    # Delete the temporary directory where chunks used to be.
    def delete_chunk_temp_dir!
      return if !chunk_temp_dir || !chunk_temp_dir.exist?
      chunk_temp_dir.delete
    end
  end
end

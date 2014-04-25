module VimeoVideos
  # Handles checking space, splitting video into smaller chunks,
  # uploading them, veryfing them and a cleanup.
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

    # @return [Array<Hash>] array of chunks (video split into pieces)
    attr_accessor :chunks

    # @return [Fixnum] to how many pieces split the video into
    attr_accessor :number_of_chunks

    # @return [Hash] :id, :endpoint_secure, :max_file_size
    attr_accessor :ticket

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
  end
end

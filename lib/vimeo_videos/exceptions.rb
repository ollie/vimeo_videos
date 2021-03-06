module VimeoVideos
  # StandardError
  #   BaseError
  #     ClientError
  #     UploadError
  #       NoEnoughFreeSpaceError
  #       MaxFileSizeExceededError
  #       ChunkUploadFailed
  #       ChunkCountError
  #       ChunkSizeError

  # General API exception.
  class BaseError < StandardError; end

  # Raised when +stat+ in response is not +ok+.
  class ClientError < BaseError; end

  # General upload error.
  class UploadError < BaseError; end

  # Raised when a video cannot fit into user's quota.
  class NoEnoughFreeSpaceError < UploadError; end

  # Raised when a file cannot fit into an upload ticket max_file_size.
  class MaxFileSizeExceededError < UploadError; end

  # Raised when a file cannot be uploaded for some reason.
  class ChunkUploadFailed < UploadError; end

  # Chunk count differs.
  class ChunkCountError < UploadError; end

  # Chunk size differs.
  class ChunkSizeError < UploadError; end
end

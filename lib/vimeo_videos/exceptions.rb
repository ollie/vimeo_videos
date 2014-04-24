module VimeoVideos
  # StandardError
  #   BaseError
  #     ClientError
  #     UploadError
  #       NoEnoughFreeSpaceError
  #       MaxFileSizeExceededError

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
end

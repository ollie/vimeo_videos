module VimeoVideos
  # General API exception.
  class ApiError < StandardError; end

  # Raised when +stat+ in response is not +ok+.
  class RequestError < ApiError; end

  # General upload error.
  class UploadError < ApiError; end

  # Raised when a video cannot fit into user's quota.
  class NoEnoughFreeSpaceError < UploadError; end
end

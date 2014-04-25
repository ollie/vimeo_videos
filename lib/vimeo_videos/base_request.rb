module VimeoVideos
  # Base class for all the requests.
  class BaseRequest
    # The Vimeo V2 endpoint.
    API_URL = 'https://vimeo.com/api/rest/v2'

    # That's us.
    USER_AGENT = 'VimeoVideos (https://github.com/ollie/vimeo_videos)'

    # OJ-related options.
    OJ_OPTIONS = {
      mode:             :compat,    # Converts values with to_hash or to_json
      symbol_keys:      true,       # Symbol keys to string keys
      time_format:      :xmlschema, # ISO8061 format
      second_precision: 0,          # No include milliseconds
    }

    # @return [Client] Client instance
    attr_accessor :client

    # It's good to have a reference back to the client.
    #
    # @param client [Client] the client has OAuth settings
    def initialize(client)
      self.client = client
    end
  end
end

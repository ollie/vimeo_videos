module VimeoVideos
  class Client
    # Some 3rd party options extracted away.
    module Defaults
      # OJ-related options.
      OJ_OPTIONS = {
        mode:             :compat,    # Converts values with to_hash or to_json
        symbol_keys:      true,       # Symbol keys to string keys
        time_format:      :xmlschema, # ISO8061 format
        second_precision: 0,          # No include milliseconds
      }
    end
  end
end

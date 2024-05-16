# frozen_string_literal: true

module RateLimit
  class Config
    module Defaults
      # Limits File Path
      LIMITS_FILE_PATH = 'config/rate-limit.yml'

      # Fixed Window Defaults
      WINDOW_INTERVAL = 60
      WINDOW_THRESHOLD = 2

      class << self
        def raw_limits
          {
            RateLimit.config.default_threshold => RateLimit.config.default_interval
          }
        end
      end
    end
  end
end

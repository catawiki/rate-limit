# frozen_string_literal: true

require 'redis'
require_relative 'config/defaults'
require_relative 'config/file_loader'

module RateLimit
  class Config
    attr_accessor :default_interval,
                  :default_threshold,
                  :limits_file_path,
                  :on_success,
                  :on_failure,
                  :fail_safe,
                  :redis

    def initialize
      @redis             = Redis.new
      @fail_safe         = true
      @limits_file_path  = Defaults::LIMITS_FILE_PATH
      @default_interval  = Defaults::WINDOW_INTERVAL
      @default_threshold = Defaults::WINDOW_THRESHOLD
    end

    def raw_limits_for(topic)
      raw_limits[topic] || Defaults.raw_limits
    end

    def success_callback(*args)
      on_success&.call(*args)
    end

    def failure_callback(*args)
      on_failure&.call(*args)
    end

    private

    def raw_limits
      @raw_limits ||= FileLoader.fetch
    end
  end
end

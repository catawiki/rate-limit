# frozen_string_literal: true

require_relative 'config'

module RateLimit
  module Configurable
    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
    end
  end
end

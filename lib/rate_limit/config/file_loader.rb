# frozen_string_literal: true

require 'yaml'

module RateLimit
  class Config
    module FileLoader
      def self.fetch
        return {} unless File.exist?(RateLimit.config.limits_file_path)

        YAML.load_file(RateLimit.config.limits_file_path)
      end
    end
  end
end

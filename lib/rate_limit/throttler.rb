# frozen_string_literal: true

module RateLimit
  class Throttler
    attr_accessor :topic, :namespace, :value, :limits, :windows

    def initialize(topic:, value:, namespace: nil)
      @topic     = topic.to_s
      @value     = value.to_i
      @namespace = namespace&.to_s
      @windows   = Limit.fetch(topic).map { |limit| Window.new(self, limit) }
    end

    def perform!
      validate_limit!

      yield if block_given?

      increment_cache_counter

      true
    end

    def perform_only_failures!
      validate_limit!

      begin
        yield if block_given?
      rescue StandardError => e
        increment_cache_counter
        raise e
      end

      true
    end

    def limit_exceeded?
      Window.find_exceeded(windows).present?
    end

    def increment_cache_counter
      Window.increment_cache_counter(windows)
    end

    def clear_cache_counter
      Window.clear_cache_counter(windows)
    end

    private

    def validate_limit!
      exceeded_window = Window.find_exceeded(windows)

      raise Errors::LimitExceededError, exceeded_window if exceeded_window
    end
  end
end

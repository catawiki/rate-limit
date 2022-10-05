# frozen_string_literal: true

module RateLimit
  class Worker
    include Throttler

    attr_accessor :topic, :value, :limits, :windows, :exceeded_window, :result, :raise_errors, :only_failures

    def initialize(topic:, value:, raise_errors: false, only_failures: false)
      @topic         = topic.to_s
      @value         = value.to_s
      @windows       = Window.find_all(worker: self, topic: @topic)
      @result        = Result.new(topic: @topic, value: @value)
      @raise_errors = raise_errors
      @only_failures = only_failures
    end

    def increment_cache_counter
      Window.increment_cache_counter(windows)
    end

    def clear_cache_counter
      Window.clear_cache_counter(windows)
    end

    def reloaded_limit_exceeded?
      @exceeded_window = Window.find_exceeded(windows)

      limit_exceeded?
    end

    def limit_exceeded?
      exceeded_window.present?
    end

    def success!
      increment_cache_counter
      result.success!
      RateLimit.config.success_callback(result)
    end

    def failure!
      result.failure!(self)
      RateLimit.config.failure_callback(result)

      raise Errors::LimitExceededError, result if raise_errors
    end
  end
end

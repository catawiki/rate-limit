# frozen_string_literal: true

module RateLimit
  class Worker
    include Throttler

    attr_accessor :topic, :namespace, :value, :limits, :windows, :exceeded_window, :result

    def initialize(topic:, value:, namespace: nil)
      @topic     = topic.to_s
      @value     = value.to_i
      @namespace = namespace&.to_s
      @windows   = Window.find_all(worker: self, topic: @topic)
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
      @result = Result.new(self, true)
      RateLimit.config.success_callback(result)
    end

    def failure!
      @result = Result.new(self, false)
      RateLimit.config.failure_callback(result)
    end
  end
end

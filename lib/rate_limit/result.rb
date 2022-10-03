# frozen_string_literal: true

module RateLimit
  class Result
    # Attributes
    attr_accessor :topic, :value, :threshold, :interval

    # Methods
    def initialize(topic:, value:)
      @topic = topic
      @value = value
    end

    def success?
      @success
    end

    def success!
      @success = true
      RateLimit.config.success_callback(self)
    end

    def failure!(worker, fail_safe)
      @success = false
      @threshold  = worker.exceeded_window&.threshold
      @interval   = worker.exceeded_window&.interval
      RateLimit.config.failure_callback(self)

      raise Errors::LimitExceededError, self unless fail_safe
    end
  end
end

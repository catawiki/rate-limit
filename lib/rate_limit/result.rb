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
    end

    def failure!(worker)
      @success = false
      @threshold  = worker.exceeded_window&.threshold
      @interval   = worker.exceeded_window&.interval
    end
  end
end

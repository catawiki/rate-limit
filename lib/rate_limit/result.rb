# frozen_string_literal: true

module RateLimit
  class Result
    # Attributes
    attr_accessor :topic, :value, :threshold, :interval

    # Methods
    def initialize(worker, success)
      @topic      = worker.topic
      @value      = worker.value
      @threshold  = worker.exceeded_window&.threshold
      @interval   = worker.exceeded_window&.interval
      @success    = success
    end

    def success?
      @success
    end
  end
end

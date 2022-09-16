# frozen_string_literal: true

module RateLimit
  class Result
    # Attributes
    attr_accessor :topic, :namespace, :value, :threshold, :interval

    # Methods
    def initialize(worker, success)
      @topic      = worker.topic
      @namespace  = worker.namespace
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

# frozen_string_literal: true

module RateLimit
  class Result
    # Attributes
    attr_accessor :worker

    # Delegations
    delegate :topic, :namespace, :value, :exceeded_window, :limit_exceeded?, to: :worker
    delegate :threshold, :interval, to: :exceeded_window

    # Methods
    def initialize(worker, success)
      @worker = worker
      @success = success
    end

    def success?
      @success
    end
  end
end

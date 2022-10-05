# frozen_string_literal: true

module RateLimit
  module Throttler
    def throttle
      return failure! if limit_exceeded?

      yield if block_given?

      return success! unless only_failures
    rescue StandardError => e
      success! unless e.is_a?(Errors::LimitExceededError)
      raise e
    end
  end
end

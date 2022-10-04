# frozen_string_literal: true

module RateLimit
  module Throttler
    def throttle
      return failure! if reloaded_limit_exceeded?

      yield if block_given?

      return success! unless only_failures
    rescue Errors::LimitExceededError => e
      raise e
    rescue StandardError => e
      success!
      raise e
    end
  end
end

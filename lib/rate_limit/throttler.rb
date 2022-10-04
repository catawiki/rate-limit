# frozen_string_literal: true

module RateLimit
  module Throttler
    def throttle
      return failure! if reloaded_limit_exceeded?

      unless only_failures
        yield if block_given?

        return success!
      end

      yield if block_given?
    rescue StandardError => e
      success!
      raise e
    end
  end
end

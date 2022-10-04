# frozen_string_literal: true

module RateLimit
  module Throttler
    def throttle
      return failure! if reloaded_limit_exceeded?

      success!
    end

    def throttle_with_block!
      failure!(raise_errors: true) if reloaded_limit_exceeded?

      yield

      success!
    end

    def throttle_only_failures_with_block!
      return failure! if reloaded_limit_exceeded?

      begin
        yield
      rescue StandardError => e
        success!
        raise e
      end
    end
  end
end

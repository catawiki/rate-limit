# frozen_string_literal: true

module RateLimit
  module Base
    def throttle(**args)
      throttle!(**args) { yield if block_given? }
    rescue Errors::LimitExceededError => _e
      false
    end

    def throttle!(**args)
      Throttler.new(**args).perform! { yield if block_given? }
    end

    def throttle_only_failures!(**args)
      Throttler.new(**args).perform_only_failures! { yield if block_given? }
    end

    def limit_exceeded?(**args)
      Throttler.new(**args).limit_exceeded?
    end

    def reset_counters(**args)
      Throttler.new(**args).clear_cache_counter
    end

    def increment_counters(**args)
      Throttler.new(**args).increment_cache_counter
    end
  end
end

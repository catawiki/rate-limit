# frozen_string_literal: true

module RateLimit
  module Base
    def throttle(**args)
      worker = Worker.new(**args)
      worker.throttle
      worker.result
    end

    def throttle_with_block!(**args, &block)
      worker = Worker.new(**args)

      worker.throttle_with_block!(&block)
      worker.result
    end

    def throttle_only_failures_with_block!(**args, &block)
      worker = Worker.new(**args)

      worker.throttle_only_failures_with_block!(&block)
      worker.result
    end

    def limit_exceeded?(**args)
      Worker.new(**args).reloaded_limit_exceeded?
    end

    def reset_counters(**args)
      Worker.new(**args).clear_cache_counter
    end

    def increment_counters(**args)
      Worker.new(**args).increment_cache_counter
    end
  end
end

# frozen_string_literal: true

module RateLimit
  module Base
    def throttle(**args)
      worker = Worker.new(**args)
      worker.throttle { yield if block_given? }
      worker.result
    end

    def limit_exceeded?(**args)
      Worker.new(**args).limit_exceeded?
    end

    def reset_counters(**args)
      Worker.new(**args).clear_cache_counter
    end

    def increment_counters(**args)
      Worker.new(**args).increment_cache_counter
    end
  end
end

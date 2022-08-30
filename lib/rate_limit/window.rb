# frozen_string_literal: true

module RateLimit
  class Window
    attr_accessor :throttler, :limit

    delegate :topic, :namespace, :value, to: :throttler
    delegate :threshold, :interval, to: :limit

    def initialize(throttler, limit)
      @throttler = throttler
      @limit     = limit
    end

    def key
      @key ||= [topic, namespace, value, interval].join(':')
    end

    def cached_counter
      Cache.read(key).to_i || 0
    end

    class << self
      def find_exceeded(windows)
        windows.find { |w| w.cached_counter >= w.threshold }
      end

      def increment_cache_counter(windows)
        Cache.write(
          windows.each_with_object({}) { |w, h| h[w.key] = w.interval }
        )
      end

      def clear_cache_counter(windows)
        Cache.clear(windows.map(&:key))
      end
    end
  end
end

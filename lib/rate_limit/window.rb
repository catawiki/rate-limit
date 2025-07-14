# frozen_string_literal: true

module RateLimit
  class Window
    attr_accessor :worker, :limit

    delegate :topic, :value, to: :worker
    delegate :threshold, :interval, to: :limit

    def initialize(worker, limit)
      @worker = worker
      @limit = limit
    end

    def key
      @key ||= [topic, value, interval].join(':')
    end

    def cached_counter
      (Cache.read(key) || 0).to_i
    end

    class << self
      def find_all(topic:, worker:)
        Limit.fetch(topic).map { |limit| Window.new(worker, limit) }
      end

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

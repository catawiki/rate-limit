# frozen_string_literal: true

module RateLimit
  module Cache
    class << self
      def write(options)
        RateLimit.config.redis.multi do |redis|
          options.each do |key, value|
            redis.incr(key)
            redis.expire(key, value)
          end
        end
      rescue ::Redis::BaseError => e
        return true if RateLimit.config.fail_safe

        raise e
      end

      def read(key)
        RateLimit.config.redis.get(key)
      rescue ::Redis::BaseError => e
        return 0 if RateLimit.config.fail_safe

        raise e
      end

      def clear(keys)
        RateLimit.config.redis.multi do |redis|
          keys.each { |k| redis.del(k) }
        end
      rescue ::Redis::BaseError => e
        return true if RateLimit.config.fail_safe

        raise e
      end
    end
  end
end

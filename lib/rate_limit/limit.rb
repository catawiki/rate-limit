# frozen_string_literal: true

module RateLimit
  class Limit
    attr_accessor :threshold, :interval

    def initialize(threshold, interval)
      @threshold = threshold
      @interval  = interval
    end

    class << self
      def fetch(topic)
        RateLimit.config.raw_limits_for(topic).map do |threshold, interval|
          Limit.new(threshold, interval)
        end
      end
    end
  end
end

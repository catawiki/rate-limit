# frozen_string_literal: true

module RateLimit
  module Errors
    class LimitExceededError < StandardError
      attr_reader :result

      delegate :topic, :value, :threshold, :interval, to: :result

      def initialize(result)
        @result = result

        super(custom_message)
      end

      def custom_message
        "#{result.topic}: has exceeded #{result.threshold} in #{result.interval} seconds"
      end
    end
  end
end

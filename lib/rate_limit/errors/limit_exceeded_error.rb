# frozen_string_literal: true

module RateLimit
  module Errors
    class LimitExceededError < StandardError
      attr_reader :window

      delegate :topic, :namespace, :value, :threshold, :interval, to: :window

      def initialize(window)
        @window = window

        super(custom_message)
      end

      def custom_message
        "#{topic}: #{namespace} has exceeded #{threshold} in #{interval} seconds"
      end
    end
  end
end

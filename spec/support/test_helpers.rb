# frozen_string_literal: true

module RateLimit
  module Test
    module CallbackHelper
      def self.success(result); end
      def self.failure(result); end
    end

    module YeildHelper
      def self.perform(faulty: false)
        raise YeildError if faulty
      end
    end

    class YeildError < StandardError; end
  end
end

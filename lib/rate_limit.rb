# frozen_string_literal: true

require 'active_support/core_ext/module'
require_relative 'rate_limit/configurable'
require_relative 'rate_limit/cache'
require_relative 'rate_limit/window'
require_relative 'rate_limit/throttler'
require_relative 'rate_limit/limit'
require_relative 'rate_limit/errors/limit_exceeded_error'
require_relative 'rate_limit/base'
require_relative 'rate_limit/version'

module RateLimit
  extend RateLimit::Configurable
  extend RateLimit::Base
end

# frozen_string_literal: true

require 'active_support/core_ext/kernel'
require 'rate_limit'
require 'byebug'
require 'simplecov'

SimpleCov.start

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.before { Redis.new.flushall }

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

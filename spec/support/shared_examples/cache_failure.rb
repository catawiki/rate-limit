# frozen_string_literal: true

RSpec.shared_examples_for 'CacheFailure' do |func_name|
  before { allow(redis_instance).to receive(func_name).and_raise(::Redis::BaseError) }

  let(:redis_instance) { RateLimit.config.redis = Redis.new }

  context 'when fail_safe is true' do
    before { RateLimit.config.fail_safe = false }

    after { RateLimit.config.fail_safe = true }

    it { expect { subject }.to raise_error(::Redis::BaseError) }
  end
end

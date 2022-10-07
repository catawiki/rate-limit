# frozen_string_literal: true

RSpec.shared_examples_for 'callback success' do |count|
  before do
    allow(RateLimit::Test::CallbackHelper).to receive(:success).with(kind_of(RateLimit::Result)).and_call_original

    RateLimit.config.on_success = proc { |result| RateLimit::Test::CallbackHelper.success(result) }
  end

  after { RateLimit.config.on_success = nil }

  it do
    suppress(StandardError) { result }

    expect(RateLimit::Test::CallbackHelper).to have_received(:success).exactly(count).times
  end
end

RSpec.shared_examples_for 'callback failure' do |count|
  before do
    allow(RateLimit::Test::CallbackHelper).to receive(:failure).with(kind_of(RateLimit::Result)).and_call_original

    RateLimit.config.on_failure = proc { |result| RateLimit::Test::CallbackHelper.failure(result) }
  end

  after { RateLimit.config.on_failure = nil }

  it do
    suppress(StandardError) { result }

    expect(RateLimit::Test::CallbackHelper).to have_received(:failure).exactly(count).times
  end
end

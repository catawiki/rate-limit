# frozen_string_literal: true

RSpec.shared_examples_for 'increments cache counter' do |count|
  before do
    allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args).and_call_original
  end

  it do
    suppress(RateLimit::Test::YeildError) { subject }

    expect(RateLimit::Window).to have_received(:increment_cache_counter).exactly(count).time
  end
end

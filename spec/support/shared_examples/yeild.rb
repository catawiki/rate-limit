# frozen_string_literal: true

RSpec.shared_examples_for 'a yield called' do
  before { allow(RateLimit::Test::YeildHelper).to receive(:perform).with(any_args).and_call_original }

  it do
    subject

    expect(RateLimit::Test::YeildHelper).to have_received(:perform).once
  end
end

RSpec.shared_examples_for 'a yield not called' do
  before { allow(RateLimit::Test::YeildHelper).to receive(:perform).with(any_args).and_call_original }

  it do
    suppress(RateLimit::Errors::LimitExceededError) { result }

    expect(RateLimit::Test::YeildHelper).not_to have_received(:perform)
  end
end

RSpec.shared_examples_for 'a yield raises error' do
  before { allow(RateLimit::Test::YeildHelper).to receive(:perform).with(any_args).and_call_original }

  it do
    expect { subject }.to raise_error(RateLimit::Test::YeildError)
  end
end

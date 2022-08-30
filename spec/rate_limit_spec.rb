# frozen_string_literal: true

RSpec.describe RateLimit do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  it_behaves_like RateLimit::Configurable
  it_behaves_like RateLimit::Base
end

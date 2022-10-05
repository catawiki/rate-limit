# frozen_string_literal: true

RSpec.describe RateLimit::Worker do
  subject(:worker) { described_class.new(topic: topic_login, value: value_five, only_failures: only_failures) }

  let(:topic_login) { :login }
  let(:value_five) { 5 }
  let(:only_failures) { false }

  describe '.new' do
    it { expect(worker.topic).to eq(topic_login.to_s) }
    it { expect(worker.value).to eq(value_five.to_s) }
  end

  it_behaves_like RateLimit::Throttler
end

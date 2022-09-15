# frozen_string_literal: true

RSpec.describe RateLimit::Result do
  let(:topic_login) { :login }
  let(:namespace_user_id) { 'user_id' }
  let(:value_five) { 5 }
  let(:worker) { RateLimit::Worker.new(topic: topic_login, namespace: namespace_user_id, value: value_five) }

  describe '.new' do
    subject(:result) { described_class.new(worker, true) }

    it { expect(result.topic).to eq(worker.topic) }
    it { expect(result.namespace).to eq(worker.namespace) }
    it { expect(result.value).to eq(worker.value) }
    it { expect(result.threshold).to be_nil }
    it { expect(result.interval).to be_nil }
    it { expect(result.success?).to be(true) }
  end
end

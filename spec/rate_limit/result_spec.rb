# frozen_string_literal: true

RSpec.describe RateLimit::Result do
  let(:topic_login) { :login }
  let(:namespace_user_id) { 'user_id' }
  let(:value_five) { 5 }
  let(:worker_instance) { RateLimit::Worker.new(topic: topic_login, namespace: namespace_user_id, value: value_five) }

  describe '.new' do
    subject(:result) { described_class.new(worker_instance, true) }

    it { expect(result.topic).to eq(worker_instance.topic) }
    it { expect(result.namespace).to eq(worker_instance.namespace) }
    it { expect(result.value).to eq(worker_instance.value) }
    it { expect(result.success?).to be(true) }
  end
end

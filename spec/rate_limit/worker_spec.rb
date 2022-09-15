# frozen_string_literal: true

RSpec.describe RateLimit::Worker do
  subject(:worker) { described_class.new(topic: topic_login, namespace: namespace_user_id, value: value_five) }

  let(:topic_login) { :login }
  let(:namespace_user_id) { 'user_id' }
  let(:value_five) { 5 }

  describe '.new' do
    it { expect(worker.topic).to eq(topic_login.to_s) }
    it { expect(worker.namespace).to eq(namespace_user_id) }
    it { expect(worker.value).to eq(value_five) }
  end

  it_behaves_like RateLimit::Throttler
end

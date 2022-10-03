# frozen_string_literal: true

RSpec.describe RateLimit::Result do
  let(:topic_login) { :login }
  let(:value_five) { 5 }

  describe '.new' do
    subject(:result) { described_class.new(topic: topic_login, value: value_five) }

    it { expect(result.topic).to eq(topic_login) }
    it { expect(result.value).to eq(value_five) }
    it { expect(result.threshold).to be_nil }
    it { expect(result.interval).to be_nil }

    it do
      result.success!

      expect(result.success?).to be(true)
    end
  end
end

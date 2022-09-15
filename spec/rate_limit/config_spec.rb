# frozen_string_literal: true

RSpec.describe RateLimit::Config do
  describe '.new' do
    subject(:config) { described_class.new }

    it 'returns instance redis by default' do
      expect(config.redis).to be_a(Redis)
    end

    it 'returns fail_safe' do
      expect(config.fail_safe).to be(true)
    end

    it 'returns default_threshold' do
      expect(config.default_threshold).to eq(2)
    end

    it 'returns default_interval' do
      expect(config.default_interval).to eq(60)
    end

    it 'returns limits_file_path' do
      expect(config.limits_file_path).to eq('config/rate-limit.yml')
    end

    it 'returns on_success' do
      expect(config.on_success).to be_nil
    end

    it 'returns on_failure' do
      expect(config.on_failure).to be_nil
    end
  end

  describe '#success_callback' do
    subject(:config) { described_class.new }

    before do
      config.on_success = proc { |topic| "on_success_#{topic}" }
    end

    it 'returns topic success_callback' do
      expect(config.success_callback('topic_name')).to eq('on_success_topic_name')
    end
  end

  describe '#failure_callback' do
    subject(:config) { described_class.new }

    before do
      config.on_failure = proc { |topic| "on_failure_#{topic}" }
    end

    it 'returns topic failure_callback' do
      expect(config.failure_callback('topic_name')).to eq('on_failure_topic_name')
    end
  end
end

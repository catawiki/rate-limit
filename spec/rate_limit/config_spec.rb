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
  end
end

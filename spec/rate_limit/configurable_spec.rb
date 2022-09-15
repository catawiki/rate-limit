# frozen_string_literal: true

RSpec.shared_examples_for RateLimit::Configurable do
  describe '.config' do
    subject(:config) { described_class.config }

    it 'returns config class' do
      expect(config).to be_a(described_class::Config)
    end

    it 'returns instance redis by default' do
      expect(config.redis).to be_a(Redis)
    end
  end

  describe '.configure' do
    subject(:configure) do
      described_class.configure do |c|
        c.redis = new_redis
        c.fail_safe = false
      end
    end

    after { described_class.config.fail_safe = true }

    let(:config) { described_class.config }
    let!(:default_redis) { config.redis }
    let(:new_redis) { Redis.new }

    it 'returns new redis instance' do
      configure

      expect(config.redis).to eq(new_redis)
    end

    it 'replaces default redis' do
      configure

      expect(config.redis).not_to eq(default_redis)
    end

    it 'changes fail_safe option' do
      expect { configure }.to(change(config, :fail_safe).from(true).to(false))
    end
  end
end

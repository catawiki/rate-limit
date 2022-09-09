# frozen_string_literal: true

RSpec.describe RateLimit::Throttler do
  let(:sym_topic) { :login }
  let(:topic_login) { sym_topic.to_s }
  let(:namespace_user_id) { 'user_id' }
  let(:value_five) { 5 }
  let(:options) do
    {
      topic: sym_topic,
      namespace: namespace_user_id,
      value: value_five
    }
  end

  before do
    allow(RateLimit::Config::FileLoader).to receive(:fetch).and_return({ topic_login => { 2 => 300 } })
  end

  describe '.new' do
    subject(:throttler) { described_class.new(**options) }

    it { expect(throttler.topic).to eq(topic_login) }
    it { expect(throttler.namespace).to eq(namespace_user_id) }
    it { expect(throttler.value).to eq(value_five) }
  end

  describe '#perform_only_failures!' do
    let(:throttler) { described_class.new(**options) }

    before do
      Redis.new.flushall
      allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args).and_call_original
    end

    after { Redis.new.flushall }

    it 'increments limit in cache when block is not given' do
      throttler.perform_only_failures!

      expect(RateLimit::Window).not_to have_received(:increment_cache_counter)
    end

    it 'increments limit in cache when block is given' do
      throttler.perform_only_failures! { 1 + 1 }

      expect(RateLimit::Window).not_to have_received(:increment_cache_counter)
    end

    it 'increments limit in cache when block is given with exception' do
      suppress(StandardError) do
        throttler.perform_only_failures! { raise 'Error' }
      end

      expect(RateLimit::Window).to have_received(:increment_cache_counter).once
    end

    it 'raises error when block is given with exception' do
      expect do
        throttler.perform! { raise 'Error' }
      end.to raise_error(StandardError)
    end
  end

  describe '#perform!' do
    let(:throttler) { described_class.new(**options) }

    before do
      Redis.new.flushall
      allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args).and_call_original
    end

    after { Redis.new.flushall }

    context 'when namespace attempts did not exceed limits' do
      it 'increments limit in cache when block is not given' do
        throttler.perform!

        expect(RateLimit::Window).to have_received(:increment_cache_counter).once
      end

      it 'increments limit in cache when block is given' do
        throttler.perform! { 1 + 1 }

        expect(RateLimit::Window).to have_received(:increment_cache_counter).once
      end
    end

    context 'when namespace attempts exceeds limits' do
      before do
        2.times { throttler.perform! }
      end

      it 'raises Limit Exceeded Error' do
        expect do
          throttler.perform!
        end.to raise_error(RateLimit::Errors::LimitExceededError)
      end

      context 'when error is raised' do
        subject(:error) do
          throttler.perform!
        rescue RateLimit::Errors::LimitExceededError => e
          e
        end

        it 'error topic to equal login' do
          expect(error.topic).to eq(topic_login)
        end

        it 'error namespace to equal user_id' do
          expect(error.namespace).to eq(namespace_user_id)
        end

        it 'error value to equal 5' do
          expect(error.value).to eq(value_five)
        end

        it 'error threshold to equal 2' do
          expect(error.threshold).to eq(2)
        end

        it 'error interval to equal 60' do
          expect(error.interval).to eq(300)
        end
      end
    end
  end
end

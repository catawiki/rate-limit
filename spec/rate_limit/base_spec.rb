# frozen_string_literal: true

RSpec.shared_examples_for RateLimit::Base do
  before { redis_instance.flushall }

  after { redis_instance.flushall }

  let(:redis_instance) { RateLimit.config.redis = Redis.new }
  let(:topic_login) { 'login' }
  let(:namespace_user_id) { 'user_id' }
  let(:value_five) { 5 }
  let(:options) { { topic: topic_login, namespace: namespace_user_id, value: value_five } }

  shared_examples_for 'CacheFailure' do |func_name|
    before { allow(redis_instance).to receive(func_name).and_raise(::Redis::BaseError) }

    context 'when fail_safe is true' do
      before { RateLimit.config.fail_safe = false }

      after { RateLimit.config.fail_safe = true }

      it { expect { subject }.to raise_error(::Redis::BaseError) }
    end
  end

  describe '.increment_counters' do
    subject(:increment_counters) do
      described_class.increment_counters(**options)
    end

    it_behaves_like 'CacheFailure', :multi

    context 'when namespace attempts exceed limits' do
      before { described_class.throttle(**options) }

      let!(:throttler) { RateLimit::Throttler.new(**options) }

      it do
        expect { increment_counters }.to(
          change { throttler.windows.map(&:cached_counter) }.from([1]).to([2])
        )
      end
    end
  end

  describe '.reset_counters' do
    subject(:reset_counters) { described_class.reset_counters(**options) }

    it_behaves_like 'CacheFailure', :multi

    context 'when namespace attempts exceed limits' do
      before { described_class.throttle(**options) }

      let!(:throttler) { RateLimit::Throttler.new(**options) }

      it do
        expect { reset_counters }.to(
          change { throttler.windows.map(&:cached_counter) }.from([1]).to([0])
        )
      end
    end
  end

  describe '.limit_exceeded?' do
    subject(:limit_exceeded?) { described_class.limit_exceeded?(**options) }

    it_behaves_like 'CacheFailure', :get

    context 'when namespace attempts exceed limits' do
      before { 3.times { described_class.throttle(**options) } }

      it { is_expected.to be(true) }
    end

    context 'when namespace attempts did not exceed limits' do
      it { is_expected.to be(false) }
    end
  end

  describe '.throttle' do
    subject(:throttle) { described_class.throttle(**options) }

    it_behaves_like 'CacheFailure', :get

    context 'when namespace attempts did not exceed limits' do
      before do
        allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args)
      end

      it 'increments limit in cache' do
        throttle

        expect(RateLimit::Window).to have_received(:increment_cache_counter).once
      end

      context 'when block is provided' do
        subject(:throttle_with_block) do
          described_class.throttle(**options) do
            Hash.new(0)
          end
        end

        before { allow(Hash).to receive(:new) }

        it 'calls yield' do
          throttle_with_block

          expect(Hash).to have_received(:new).once
        end
      end

      context 'when namespace is null' do
        subject(:throttle_with_block) do
          described_class.throttle(topic: topic_login, value: value_five) do
            Hash.new(0)
          end
        end

        before { allow(Hash).to receive(:new) }

        it 'calls yield' do
          throttle_with_block

          expect(Hash).to have_received(:new).once
        end

        it do
          expect(described_class.limit_exceeded?(topic: topic_login, value: value_five)).to be(false)
        end
      end
    end

    context 'when namespace attempts exceeds limits' do
      before { 2.times { described_class.throttle(**options) } }

      it 'returns false' do
        expect(throttle).to be(false)
      end
    end
  end

  describe '.throttle!' do
    subject(:throttle!) { described_class.throttle!(**options) }

    it_behaves_like 'CacheFailure', :get

    context 'when namespace attempts did not exceed limits' do
      before do
        allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args)
      end

      it 'increments limit in cache' do
        throttle!

        expect(RateLimit::Window).to have_received(:increment_cache_counter).once
      end

      context 'when block is provided' do
        subject(:throttle_with_block!) do
          described_class.throttle!(**options) do
            Hash.new(0)
          end
        end

        before { allow(Hash).to receive(:new) }

        it 'calls yield' do
          throttle_with_block!

          expect(Hash).to have_received(:new).once
        end
      end
    end

    context 'when namespace attempts exceeds limits' do
      before { 2.times { described_class.throttle!(**options) } }

      it 'raises Limit Exceeded Error' do
        expect do
          throttle!
        end.to raise_error(RateLimit::Errors::LimitExceededError)
      end
    end

    context 'when nested throttles are called' do
      subject(:nested_throttle!) do
        RateLimit.throttle!(**options) do
          RateLimit.throttle!(topic: topic_login, namespace: :phone_number, value: '0000000099') do
            Hash.new(1)
          end
        end
      end

      before { allow(Hash).to receive(:new) }

      context 'when attempts did not exceed limits' do
        it 'calls yield' do
          nested_throttle!

          expect(Hash).to have_received(:new).once
        end
      end

      context 'when attempts exceeded limits' do
        before do
          2.times do
            RateLimit.throttle!(**options) do
              RateLimit.throttle!(topic: topic_login, namespace: :phone_number, value: '0000000099') do
                Hash.new(1)
              end
            end
          end
        end

        it 'raises Limit Exceeded Error' do
          expect do
            nested_throttle!
          end.to raise_error(RateLimit::Errors::LimitExceededError)
        end

        it 'exceeded limit for atribute 1' do
          expect(RateLimit.limit_exceeded?(**options)).to be(true)
        end

        it 'exceeded limit for atribute 2' do
          expect(
            RateLimit.limit_exceeded?(topic: topic_login, namespace: :phone_number, value: '0000000099')
          ).to be(true)
        end
      end
    end
  end

  describe '.throttle_only_failures!' do
    subject(:throttle_only_failures!) { described_class.throttle_only_failures!(**options) }

    it_behaves_like 'CacheFailure', :get

    context 'when namespace attempts did not exceed limits' do
      before do
        allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args)
      end

      it 'does not increment limit in cache' do
        throttle_only_failures!

        expect(RateLimit::Window).not_to have_received(:increment_cache_counter)
      end

      context 'when block is provided' do
        subject(:throttle_only_failures_with_block!) do
          described_class.throttle_only_failures!(**options) do
            Hash.new(0)
          end
        end

        before { allow(Hash).to receive(:new) }

        it 'calls yield' do
          throttle_only_failures_with_block!

          expect(Hash).to have_received(:new).once
        end
      end

      context 'when block is provided with exception' do
        subject(:throttle_only_failures_with_block!) do
          described_class.throttle_only_failures!(**options) do
            raise 'Error'
          end
        end

        before { allow(Hash).to receive(:new) }

        it 'does not increment limit in cache' do
          suppress(StandardError) do
            throttle_only_failures_with_block!
          end

          expect(RateLimit::Window).to have_received(:increment_cache_counter).once
        end
      end
    end

    context 'when nested throttle_only_failuress are called' do
      subject(:nested_throttle_only_failures!) do
        RateLimit.throttle_only_failures!(**options) do
          RateLimit.throttle_only_failures!(topic: topic_login, namespace: :phone_number, value: '0000000099') do
            Hash.new(1)
          end
        end
      end

      before { allow(Hash).to receive(:new) }

      context 'when attempts did not exceed limits' do
        it 'calls yield' do
          nested_throttle_only_failures!

          expect(Hash).to have_received(:new).once
        end
      end

      context 'when attempts exceeded limits' do
        before do
          2.times do
            suppress(StandardError) do
              RateLimit.throttle_only_failures!(**options) do
                RateLimit.throttle_only_failures!(topic: topic_login, namespace: :phone_number, value: '0000000099') do
                  raise 'Error'
                end
              end
            end
          end
        end

        it 'raises Limit Exceeded Error' do
          expect do
            nested_throttle_only_failures! { raise 'Error' }
          end.to raise_error(RateLimit::Errors::LimitExceededError)
        end

        it 'exceeded limit for atribute 1' do
          expect(RateLimit.limit_exceeded?(**options)).to be(true)
        end

        it 'exceeded limit for atribute 2' do
          expect(
            RateLimit.limit_exceeded?(topic: topic_login, namespace: :phone_number, value: '0000000099')
          ).to be(true)
        end
      end
    end
  end
end

# frozen_string_literal: true

RSpec.shared_examples_for RateLimit::Base do
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

      let!(:worker) { RateLimit::Worker.new(**options) }

      it do
        expect { increment_counters }.to(
          change { worker.windows.map(&:cached_counter) }.from([1]).to([2])
        )
      end
    end
  end

  describe '.reset_counters' do
    subject(:reset_counters) { described_class.reset_counters(**options) }

    it_behaves_like 'CacheFailure', :multi

    context 'when namespace attempts exceed limits' do
      before { described_class.throttle(**options) }

      let!(:worker) { RateLimit::Worker.new(**options) }

      it do
        expect { reset_counters }.to(
          change { worker.windows.map(&:cached_counter) }.from([1]).to([0])
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
    subject(:returned_object) { described_class.throttle(**options) }

    it_behaves_like 'CacheFailure', :get

    context 'when namespace attempts did not exceed limits' do
      before do
        allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args)
      end

      it 'increments limit in cache' do
        returned_object

        expect(RateLimit::Window).to have_received(:increment_cache_counter).once
      end
    end
  end

  describe '.throttle_with_block!' do
    subject(:returned_object) { described_class.throttle_with_block!(**options) }

    it_behaves_like 'CacheFailure', :get

    context 'when namespace attempts did not exceed limits' do
      before do
        allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args)
      end

      context 'when namespace is provided' do
        subject(:throttle_with_block) do
          described_class.throttle_with_block!(**options) do
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
          described_class.throttle_with_block!(topic: topic_login, value: value_five) do
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
      before { 2.times { described_class.throttle_with_block!(**options) { Hash.new(0) } } }

      it 'returns false' do
        suppress(RateLimit::Errors::LimitExceededError) do
          expect(returned_object.limit_exceeded?).to be(true)
        end
      end
    end
  end

  describe '.throttle_only_failures_with_block!' do
    subject(:throttle_only_failures_with_block!) { described_class.throttle_only_failures_with_block!(**options) }

    it_behaves_like 'CacheFailure', :get

    context 'when namespace attempts did not exceed limits' do
      before do
        allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args)
      end

      context 'when block is provided' do
        subject(:throttle_only_failures_with_block!) do
          described_class.throttle_only_failures_with_block!(**options) do
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
          described_class.throttle_only_failures_with_block!(**options) do
            raise 'Error'
          end
        end

        before { allow(Hash).to receive(:new) }

        it 'does not increment limit in cache' do
          suppress(StandardError) do
            throttle_only_failures_with_block! { Hash.new(0) }
          end

          expect(RateLimit::Window).to have_received(:increment_cache_counter).once
        end
      end
    end
  end
end

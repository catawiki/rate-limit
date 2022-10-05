# frozen_string_literal: true

RSpec.shared_examples_for RateLimit::Base do
  let(:topic_login) { 'login' }
  let(:value_five) { 5 }
  let(:raise_errors) { false }

  shared_examples_for 'CacheFailure' do |func_name|
    before { allow(redis_instance).to receive(func_name).and_raise(::Redis::BaseError) }

    let(:redis_instance) { RateLimit.config.redis = Redis.new }

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

    let(:options) { { topic: topic_login, value: value_five } }

    it_behaves_like 'CacheFailure', :multi

    context 'when topic attempts exceed limits' do
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

    let(:options) { { topic: topic_login, value: value_five } }

    it_behaves_like 'CacheFailure', :multi

    context 'when topic attempts exceed limits' do
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

    let(:options) { { topic: topic_login, value: value_five } }

    it_behaves_like 'CacheFailure', :get

    context 'when topic attempts exceed limits' do
      before { 3.times { described_class.throttle(**options) } }

      it { is_expected.to be(true) }
    end

    context 'when topic attempts did not exceed limits' do
      it { is_expected.to be(false) }
    end
  end

  describe '.throttle' do
    subject(:returned_object) { described_class.throttle(**options) }

    let(:options) { { topic: topic_login, value: value_five, raise_errors: raise_errors } }

    it_behaves_like 'CacheFailure', :get

    context 'when attempts did not exceed limits' do
      before do
        allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args)
      end

      it 'increments limit in cache' do
        returned_object

        expect(RateLimit::Window).to have_received(:increment_cache_counter).once
      end
    end

    context 'when throttle with block attempts did not exceed limits' do
      subject(:throttle_with_block) do
        described_class.throttle(**options) do
          Hash.new(0)
        end
      end

      before { allow(Hash).to receive(:new).with(any_args) }

      it 'calls yield' do
        throttle_with_block

        expect(Hash).to have_received(:new).with(0).once
      end
    end

    context 'when throttle with block attempts exceeds limits' do
      before { 2.times { described_class.throttle(**options) { Hash.new(0) } } }

      let(:raise_errors) { true }

      it 'returns false' do
        suppress(RateLimit::Errors::LimitExceededError) do
          expect(returned_object.limit_exceeded?).to be(true)
        end
      end
    end

    context 'when nested throttles are called' do
      subject(:nested_throttle!) do
        described_class.throttle(**options) do
          described_class.throttle(topic: 'other_topic', value: 55) do
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
        let(:raise_errors) { true }

        before do
          2.times do
            described_class.throttle(**options) do
              described_class.throttle(topic: 'other_topic', value: 55) do
                []
              end
            end
          end
        end

        it 'raises Limit Exceeded Error' do
          expect do
            nested_throttle!
          end.to raise_error(RateLimit::Errors::LimitExceededError)
        end

        it 'does not call Hash.new' do
          suppress(RateLimit::Errors::LimitExceededError) do
            nested_throttle!
          end

          expect(Hash).not_to have_received(:new).with(any_args)
        end

        it 'exceeded limit for atribute 1' do
          expect(described_class.limit_exceeded?(**options)).to be(true)
        end

        it 'exceeded limit for atribute 2' do
          expect(
            described_class.limit_exceeded?(topic: topic_login, value: value_five)
          ).to be(true)
        end
      end
    end
  end

  describe '.throttle(only_failures)' do
    subject(:throttle_only_failures_with_block) { described_class.throttle(**options) }

    let(:options) { { topic: topic_login, value: value_five, only_failures: true } }

    it_behaves_like 'CacheFailure', :get

    context 'when topic attempts did not exceed limits' do
      before do
        allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args)
      end

      context 'when block is provided' do
        subject(:throttle_only_failures_with_block) do
          described_class.throttle(**options) do
            Hash.new(0)
          end
        end

        before { allow(Hash).to receive(:new) }

        it 'calls yield' do
          throttle_only_failures_with_block

          expect(Hash).to have_received(:new).once
        end
      end

      context 'when block is provided with exception' do
        subject(:throttle_only_failures_with_block) do
          described_class.throttle(**options) do
            raise 'Error'
          end
        end

        before { allow(Hash).to receive(:new) }

        it 'does not increment limit in cache' do
          suppress(StandardError) do
            throttle_only_failures_with_block { Hash.new(0) }
          end

          expect(RateLimit::Window).to have_received(:increment_cache_counter).once
        end
      end
    end
  end
end

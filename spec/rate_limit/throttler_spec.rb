# frozen_string_literal: true

RSpec.shared_examples_for RateLimit::Throttler do
  let(:topic_login) { :login }
  let(:value_five) { 5 }

  before do
    allow(RateLimit.config).to receive(:success_callback).with(any_args)
    allow(RateLimit.config).to receive(:failure_callback).with(any_args)
  end

  describe '#throttle_only_failures_with_block!' do
    before do
      allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args).and_call_original
    end

    let(:only_failures) { true }

    it 'increments limit in cache when block is given' do
      subject.throttle { 1 + 1 }

      expect(RateLimit::Window).not_to have_received(:increment_cache_counter)
    end

    it 'increments limit in cache when block is given with exception' do
      suppress(StandardError) do
        subject.throttle { raise 'Error' }
      end

      expect(RateLimit::Window).to have_received(:increment_cache_counter).once
    end

    it 'raises error when block is given with exception' do
      expect do
        subject.throttle { raise 'Error' }
      end.to raise_error(StandardError)
    end
  end

  describe '#throttle' do
    before do
      allow(RateLimit.config).to receive(:raw_limits).and_return({ topic_login.to_s => { 2 => 300 } })
      allow(RateLimit::Window).to receive(:increment_cache_counter).with(any_args).and_call_original
    end

    context 'when topic attempts did not exceed limits' do
      it 'increments limit in cache when block is not given' do
        subject.throttle

        expect(RateLimit::Window).to have_received(:increment_cache_counter).once
      end

      it 'calls config.success_callback' do
        subject.throttle

        expect(RateLimit.config).to have_received(:success_callback).with(subject.result)
      end
    end

    context 'when topic attempts exceeds limits' do
      before do
        3.times { subject.throttle }
      end

      let(:returned_object) { subject.result }

      it 'returns Worker Object' do
        expect(returned_object).to be_a(RateLimit::Result)
      end

      it 'returns success? as false' do
        expect(returned_object.success?).to be(false)
      end

      it 'sets topic to equal login' do
        expect(returned_object.topic).to eq(topic_login.to_s)
      end

      it 'sets value to equal 5' do
        expect(returned_object.value).to eq(value_five.to_s)
      end

      it 'sets threshold to equal 2' do
        expect(returned_object.threshold).to eq(2)
      end

      it 'sets interval to equal 60' do
        expect(returned_object.interval).to eq(300)
      end

      it 'calls config.failure_callback' do
        subject

        expect(RateLimit.config).to have_received(:failure_callback).with(returned_object)
      end
    end
  end
end

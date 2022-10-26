# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Block Faulty Throttle with raise_errors', type: :integration do
  subject(:result) do
    RateLimit.throttle(**options) { RateLimit::Test::YeildHelper.perform(faulty: true) }
  end

  let(:topic_login) { 'login' }
  let(:value_five) { 5 }

  let(:default_options) { { topic: topic_login, value: value_five } }
  let(:options) { default_options.merge(raise_errors: true) }

  it_behaves_like 'a Cache raises Error', :get

  context 'when attempts did not exceed limits' do
    it_behaves_like 'a throttler increments cache counter', 1
    it_behaves_like 'a yield raises error'
    it_behaves_like 'a callback success called', 1
  end

  context 'when throttle attempts exceeds limits' do
    before { 2.times { RateLimit.throttle(**default_options) } }

    it_behaves_like 'a yield not called'
    it_behaves_like 'a callback failure called', 1
  end
end

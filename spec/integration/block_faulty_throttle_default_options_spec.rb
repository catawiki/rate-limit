# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Block Faulty Throttle with Default Options', type: :integration do
  subject(:result) do
    RateLimit.throttle(**default_options) { RateLimit::Test::YeildHelper.perform(faulty: true) }
  end

  let(:topic_login) { 'login' }
  let(:value_five) { 5 }

  let(:default_options) { { topic: topic_login, value: value_five } }

  it_behaves_like 'CacheFailure', :get

  context 'when attempts did not exceed limits' do
    it_behaves_like 'increments cache counter', 1
    it_behaves_like 'raises yeild error'
    it_behaves_like 'callback success', 1
  end

  context 'when throttle attempts exceeds limits' do
    before { 2.times { RateLimit.throttle(**default_options) } }

    it_behaves_like 'increments cache counter', 0
    it_behaves_like 'result failure'
    it_behaves_like 'does not call yield'
    it_behaves_like 'callback failure', 1
  end
end

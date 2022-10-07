# frozen_string_literal: true

RSpec.shared_examples_for 'result success' do
  it do
    expect(result.success?).to be(true)
  end
end

RSpec.shared_examples_for 'result failure' do
  it do
    expect(result.success?).to be(false)
  end
end

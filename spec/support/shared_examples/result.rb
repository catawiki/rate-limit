# frozen_string_literal: true

RSpec.shared_examples_for 'a result succeeded' do
  it do
    expect(result.success?).to be(true)
  end
end

RSpec.shared_examples_for 'a result failed' do
  it do
    expect(result.success?).to be(false)
  end
end

# frozen_string_literal: true

RSpec.describe Magick::Enum, '#to_s' do
  it 'works' do
    enum = described_class.new(:foo, 42)
    expect(enum.to_s).to eq('foo')

    enum = described_class.new('foo', 42)
    expect(enum.to_s).to eq('foo')
  end

  # Regression: an Enum made with allocate but never initialized has no symbol,
  # so to_s called rb_id2name(0), which returned NULL and raised ArgumentError.
  it 'does not raise for an Enum created with allocate' do
    enum = described_class.allocate
    expect(enum.to_s).to eq('')
  end
end

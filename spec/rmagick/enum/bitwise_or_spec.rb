# frozen_string_literal: true

RSpec.describe Magick::Enum, '#|' do
  it 'works' do
    enum1 = described_class.new(:foo, 42)
    enum2 = described_class.new(:bar, 56)

    enum = enum1 | enum2
    expect(enum.to_i).to eq(58)
    expect(enum.to_s).to eq('foo|bar')

    expect { enum1 | 'x' }.to raise_error(ArgumentError)
  end

  # Regression: an operand made with allocate but never initialized has no
  # symbol, so | passed the NULL from rb_id2name(0) to rb_sprintf.
  it 'treats an operand created with allocate as having no name' do
    enum = described_class.new(:foo, 42) | described_class.allocate
    expect(enum.to_s).to eq('foo|')
  end
end

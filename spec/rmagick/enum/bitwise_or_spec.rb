RSpec.describe Magick::Enum, '#|' do
  it 'works' do
    enum1 = described_class.new(:foo, 42)
    enum2 = described_class.new(:bar, 56)

    enum = enum1 | enum2
    expect(enum.to_i).to eq(58)
    expect(enum.to_s).to eq('foo|bar')

    expect { enum1 | 'x' }.to raise_error(ArgumentError)
  end
end

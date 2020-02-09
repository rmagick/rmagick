RSpec.describe Magick::Enum, '#to_i' do
  it 'works' do
    enum = described_class.new(:foo, 42)
    expect(enum.to_i).to eq(42)
  end
end

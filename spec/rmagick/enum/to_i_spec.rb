RSpec.describe Magick::Enum, '#to_i' do
  it 'works' do
    enum = Magick::Enum.new(:foo, 42)
    expect(enum.to_i).to eq(42)
  end
end

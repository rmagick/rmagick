RSpec.describe Magick::Enum, '#<=>' do
  it 'works' do
    enum1 = Magick::Enum.new(:foo, 42)
    enum2 = Magick::Enum.new(:foo, 56)
    enum3 = Magick::Enum.new(:foo, 36)
    enum4 = Magick::Enum.new(:foo, 42)

    expect(enum1 <=> enum2).to eq(-1)
    expect(enum1 <=> enum4).to eq(0)
    expect(enum1 <=> enum3).to eq(1)
    expect(enum1 <=> 'x').to be(nil)
  end
end

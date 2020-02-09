RSpec.describe Magick::Enum, '#===' do
  it 'works' do
    enum1 = described_class.new(:foo, 42)
    enum2 = described_class.new(:foo, 56)

    expect(enum1 === enum1).to be(true)
    expect(enum1 === enum2).to be(false)
    expect(enum1 === 'x').to be(false)
  end
end

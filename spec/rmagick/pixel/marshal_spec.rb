RSpec.describe Magick::Pixel, '#marshal' do
  it 'works' do
    pixel = described_class.from_color('brown')

    marshal = pixel.marshal_dump

    pixel2 = described_class.new
    expect(pixel2.marshal_load(marshal)).to eq(pixel)
  end
end

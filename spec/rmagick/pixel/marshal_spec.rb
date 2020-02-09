RSpec.describe Magick::Pixel, '#marshal' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    marshal = @pixel.marshal_dump

    pixel = described_class.new
    expect(pixel.marshal_load(marshal)).to eq(@pixel)
  end
end

RSpec.describe Magick::Pixel, '#marshal' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    marshal = @pixel.marshal_dump

    pixel = Magick::Pixel.new
    expect(pixel.marshal_load(marshal)).to eq(@pixel)
  end
end

RSpec.describe Magick::Pixel, '#dup' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    pixel = @pixel.dup
    expect(@pixel === pixel).to be(true)
    expect(pixel.object_id).not_to eq(@pixel.object_id)

    pixel = @pixel.freeze.dup
    expect(pixel.frozen?).to be(false)
  end
end

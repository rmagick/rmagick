RSpec.describe Magick::Pixel, '#clone' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    pixel = @pixel.clone
    expect(pixel).to eq(@pixel)
    expect(pixel.object_id).not_to eq(@pixel.object_id)

    pixel = @pixel.freeze.clone
    expect(pixel.frozen?).to be(true)
  end
end

RSpec.describe Magick::Pixel, '#dup' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    pixel2 = @pixel.dup
    expect(@pixel === pixel2).to be(true)
    expect(pixel2.object_id).not_to eq(@pixel.object_id)

    pixel2 = @pixel.freeze.dup
    expect(pixel2.frozen?).to be(false)
  end
end

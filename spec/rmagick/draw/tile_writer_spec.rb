RSpec.describe Magick::Draw, '#tile=' do
  it 'works' do
    draw = described_class.new

    expect { draw.tile = nil }.not_to raise_error
    expect do
      img1 = Magick::Image.new(10, 10)
      img2 = Magick::Image.new(20, 20)

      draw.tile = img1
      draw.tile = img2
    end.not_to raise_error
  end
end

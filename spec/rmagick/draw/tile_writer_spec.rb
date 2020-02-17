RSpec.describe Magick::Draw, '#tile=' do
  it 'works' do
    draw = described_class.new

    expect { draw.tile = nil }.not_to raise_error
    expect do
      image1 = Magick::Image.new(10, 10)
      image2 = Magick::Image.new(20, 20)

      draw.tile = image1
      draw.tile = image2
    end.not_to raise_error
  end
end

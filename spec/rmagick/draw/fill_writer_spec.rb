RSpec.describe Magick::Draw, '#fill=' do
  it 'works' do
    draw = described_class.new

    expect { draw.fill = 'white' }.not_to raise_error
    expect { draw.fill = Magick::Pixel.from_color('white') }.not_to raise_error
    expect { draw.fill = 2 }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Draw, '#kerning=' do
  it 'assigns without raising an error' do
    draw = described_class.new

    expect { draw.kerning = 1 }.not_to raise_error
  end

  it 'works' do
    draw = described_class.new

    expect { draw.kerning = 2 }.not_to raise_error
    expect { draw.kerning = 'x' }.to raise_error(TypeError)
  end
end

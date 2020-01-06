RSpec.describe Magick::Pixel, '#fcmp' do
  it 'works' do
    red = described_class.from_color('red')
    blue = described_class.from_color('blue')
    expect { red.fcmp(red) }.not_to raise_error
    expect(red.fcmp(red)).to be(true)
    expect(red.fcmp(blue)).to be(false)

    expect { red.fcmp(blue, 10) }.not_to raise_error
    expect { red.fcmp(blue, 10, Magick::RGBColorspace) }.not_to raise_error
    expect { red.fcmp(blue, 'x') }.to raise_error(TypeError)
    expect { red.fcmp(blue, 10, 'x') }.to raise_error(TypeError)
    expect { red.fcmp }.to raise_error(ArgumentError)
    expect { red.fcmp(blue, 10, 'x', 'y') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Pixel, '#to_color' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    expect { @pixel.to_color(Magick::AllCompliance) }.not_to raise_error
    expect { @pixel.to_color(Magick::SVGCompliance) }.not_to raise_error
    expect { @pixel.to_color(Magick::X11Compliance) }.not_to raise_error
    expect { @pixel.to_color(Magick::XPMCompliance) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, true) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, false) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, false, 8) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, false, 16) }.not_to raise_error
    # test "hex" format
    expect { @pixel.to_color(Magick::AllCompliance, false, 8, true) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, false, 16, true) }.not_to raise_error

    expect(@pixel.to_color(Magick::AllCompliance, false, 8, true)).to eq('#A52A2A')
    expect(@pixel.to_color(Magick::AllCompliance, false, 16, true)).to eq('#A5A52A2A2A2A')

    expect { @pixel.to_color(Magick::AllCompliance, false, 32) }.to raise_error(ArgumentError)
    expect { @pixel.to_color(1) }.to raise_error(TypeError)
  end

  it 'return alpha value if pixel has alpha' do
    @pixel.alpha = 123
    expect(@pixel.to_color(Magick::AllCompliance, true)).to eq('#A5A52A2A2A2A007B')
    expect(@pixel.to_color(Magick::AllCompliance, false)).to eq('brown')
  end
end

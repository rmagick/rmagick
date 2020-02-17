RSpec.describe Magick::Draw, '#interline_spacing' do
  it 'accepts a valid parameter without raising an error' do
    draw = described_class.new

    expect { draw.interline_spacing(1) }.not_to raise_error
  end

  it 'raises an error when given an invalid parameter' do
    draw = described_class.new

    expect { draw.interline_spacing('a') }.to raise_error(ArgumentError)
    expect { draw.interline_spacing([]) }.to raise_error(TypeError)
  end

  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.interline_spacing(40.5)
    expect(draw.inspect).to eq('interline-spacing 40.5')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.interline_spacing('40.5')
    expect(draw.inspect).to eq('interline-spacing 40.5')
    expect { draw.draw(image) }.not_to raise_error

    # expect { draw.interline_spacing(Float::NAN) }.to raise_error(ArgumentError)
    expect { draw.interline_spacing('nan') }.to raise_error(ArgumentError)
    expect { draw.interline_spacing('xxx') }.to raise_error(ArgumentError)
    expect { draw.interline_spacing(nil) }.to raise_error(TypeError)
  end
end

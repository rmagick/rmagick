RSpec.describe Magick::Image, '#composite_mathematics' do
  it 'works' do
    bg = described_class.new(50, 50)
    fg = described_class.new(50, 50) { self.background_color = 'black' }

    result = bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(bg)
    expect(result).not_to be(fg)

    expect { bg.composite_mathematics(fg, 1, 0, 0, 0, 0.0, 0.0) }.not_to raise_error
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity, 0.0, 0.0) }.not_to raise_error

    # too few arguments
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0) }.to raise_error(ArgumentError)
    # too many arguments
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity, 0.0, 0.0, 'x') }.to raise_error(ArgumentError)
  end
end

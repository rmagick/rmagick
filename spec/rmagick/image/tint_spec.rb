RSpec.describe Magick::Image, '#tint' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      pixels = @img.get_pixels(0, 0, 1, 1)
      @img.tint(pixels[0], 1.0)
    end.not_to raise_error
    expect { @img.tint('red', 1.0) }.not_to raise_error
    expect { @img.tint('red', 1.0, 1.0) }.not_to raise_error
    expect { @img.tint('red', 1.0, 1.0, 1.0) }.not_to raise_error
    expect { @img.tint('red', 1.0, 1.0, 1.0, 1.0) }.not_to raise_error
    expect { @img.tint }.to raise_error(ArgumentError)
    expect { @img.tint('red') }.to raise_error(ArgumentError)
    expect { @img.tint('red', 1.0, 1.0, 1.0, 1.0, 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('x', 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('red', -1.0, 1.0, 1.0, 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('red', 1.0, -1.0, 1.0, 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('red', 1.0, 1.0, -1.0, 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('red', 1.0, 1.0, 1.0, -1.0) }.to raise_error(ArgumentError)
    expect { @img.tint(1.0, 1.0) }.to raise_error(TypeError)
    expect { @img.tint('red', 'green') }.to raise_error(TypeError)
    expect { @img.tint('red', 1.0, 'green') }.to raise_error(TypeError)
    expect { @img.tint('red', 1.0, 1.0, 'green') }.to raise_error(TypeError)
    expect { @img.tint('red', 1.0, 1.0, 1.0, 'green') }.to raise_error(TypeError)
  end
end

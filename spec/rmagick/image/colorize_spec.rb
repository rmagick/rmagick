RSpec.describe Magick::Image, "#colorize" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.colorize(0.25, 0.25, 0.25, 'red')
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25, 'red') }.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.colorize(0.25, 0.25, 0.25, pixel) }.not_to raise_error
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25, pixel) }.not_to raise_error
    expect { @img.colorize }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25) }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25, 0.25) }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25, 0.25, 0.25) }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25, 0.25, 0.25, 'X') }.to raise_error(ArgumentError)
    # last argument must be a color name or pixel
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25) }.to raise_error(TypeError)
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25, 'X') }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25, [2]) }.to raise_error(TypeError)
  end
end

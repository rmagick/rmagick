RSpec.describe Magick::Image, '#frame' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.frame
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.frame(50) }.not_to raise_error
    expect { @img.frame(50, 50) }.not_to raise_error
    expect { @img.frame(50, 50, 25) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25, 6) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25, 6, 6) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25, 6, 6, 'red') }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.frame(50, 50, 25, 25, 6, 6, red) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25, 6, 6, 2) }.to raise_error(TypeError)
    expect { @img.frame(50, 50, 25, 25, 6, 6, red, 2) }.to raise_error(ArgumentError)
  end
end

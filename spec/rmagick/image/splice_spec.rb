RSpec.describe Magick::Image, '#splice' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.splice(0, 0, 2, 2)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.splice(0, 0, 2, 2, 'red') }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.splice(0, 0, 2, 2, red) }.not_to raise_error
    expect { @img.splice(0, 0, 2, 2, red, 'x') }.to raise_error(ArgumentError)
    expect { @img.splice([], 0, 2, 2, red) }.to raise_error(TypeError)
    expect { @img.splice(0, 'x', 2, 2, red) }.to raise_error(TypeError)
    expect { @img.splice(0, 0, 'x', 2, red) }.to raise_error(TypeError)
    expect { @img.splice(0, 0, 2, [], red) }.to raise_error(TypeError)
    expect { @img.splice(0, 0, 2, 2, /m/) }.to raise_error(TypeError)
  end
end

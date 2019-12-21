RSpec.describe Magick::Image, '#solarize' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.solarize
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.solarize(100) }.not_to raise_error
    expect { @img.solarize(-100) }.to raise_error(ArgumentError)
    expect { @img.solarize(Magick::QuantumRange + 1) }.to raise_error(ArgumentError)
    expect { @img.solarize(100, 2) }.to raise_error(ArgumentError)
    expect { @img.solarize('x') }.to raise_error(TypeError)
  end
end

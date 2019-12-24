RSpec.describe Magick::Image, '#wave' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.wave
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.wave(25) }.not_to raise_error
    expect { @img.wave(25, 200) }.not_to raise_error
    expect { @img.wave(25, 200, 2) }.to raise_error(ArgumentError)
    expect { @img.wave('x') }.to raise_error(TypeError)
    expect { @img.wave(25, 'x') }.to raise_error(TypeError)
  end
end

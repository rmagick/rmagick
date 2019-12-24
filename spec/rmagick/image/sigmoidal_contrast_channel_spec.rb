RSpec.describe Magick::Image, '#sigmoidal_contrast_channel' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.sigmoidal_contrast_channel
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0, true) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel, 2) }.to raise_error(TypeError)
    expect { @img.sigmoidal_contrast_channel('x') }.to raise_error(TypeError)
    expect { @img.sigmoidal_contrast_channel(3.0, 'x') }.to raise_error(TypeError)
  end
end

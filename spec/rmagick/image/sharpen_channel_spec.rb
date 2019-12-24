RSpec.describe Magick::Image, '#sharpen_channel' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.sharpen_channel
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.sharpen_channel(2.0) }.not_to raise_error
    expect { @img.sharpen_channel(2.0, 1.0) }.not_to raise_error
    expect { @img.sharpen_channel(2.0, 1.0, Magick::RedChannel) }.not_to raise_error
    expect { @img.sharpen_channel(2.0, 1.0, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.sharpen_channel(2.0, 1.0, Magick::RedChannel, 2) }.to raise_error(TypeError)
    expect { @img.sharpen_channel('x') }.to raise_error(TypeError)
    expect { @img.sharpen_channel(2.0, 'x') }.to raise_error(TypeError)
  end
end

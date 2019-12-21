RSpec.describe Magick::Image, '#gaussian_blur_channel' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.gaussian_blur_channel
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0) }.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0, 3.0) }.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel) }.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end

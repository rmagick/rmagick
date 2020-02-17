RSpec.describe Magick::Image, '#gaussian_blur_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.gaussian_blur_channel
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.gaussian_blur_channel(0.0) }.not_to raise_error
    expect { image.gaussian_blur_channel(0.0, 3.0) }.not_to raise_error
    expect { image.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel) }.not_to raise_error
    expect { image.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end

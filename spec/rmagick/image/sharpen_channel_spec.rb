RSpec.describe Magick::Image, '#sharpen_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.sharpen_channel
    expect(result).to be_instance_of(described_class)

    expect { image.sharpen_channel(2.0) }.not_to raise_error
    expect { image.sharpen_channel(2.0, 1.0) }.not_to raise_error
    expect { image.sharpen_channel(2.0, 1.0, Magick::RedChannel) }.not_to raise_error
    expect { image.sharpen_channel(2.0, 1.0, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.sharpen_channel(2.0, 1.0, Magick::RedChannel, 2) }.to raise_error(TypeError)
    expect { image.sharpen_channel('x') }.to raise_error(TypeError)
    expect { image.sharpen_channel(2.0, 'x') }.to raise_error(TypeError)
  end
end

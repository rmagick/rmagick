RSpec.describe Magick::Image, '#convolve_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.convolve_channel }.to raise_error(ArgumentError)
    expect { image.convolve_channel(0) }.to raise_error(ArgumentError)
    expect { image.convolve_channel(-1) }.to raise_error(ArgumentError)
    expect { image.convolve_channel(3) }.to raise_error(ArgumentError)
    kernel = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    order = 3

    result = image.convolve_channel(order, kernel, Magick::RedChannel)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.convolve_channel(order, kernel, Magick::RedChannel, Magick:: BlueChannel) }.not_to raise_error
    expect { image.convolve_channel(order, kernel, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end

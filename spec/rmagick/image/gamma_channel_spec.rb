RSpec.describe Magick::Image, '#gamma_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.gamma_channel(0.8)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.gamma_channel }.to raise_error(ArgumentError)
    expect { image.gamma_channel(0.8, Magick::RedChannel) }.not_to raise_error
    expect { image.gamma_channel(0.8, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.gamma_channel(0.8, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end

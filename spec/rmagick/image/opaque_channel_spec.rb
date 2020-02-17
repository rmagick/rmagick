RSpec.describe Magick::Image, '#opaque_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.opaque_channel('white', 'red')
    expect(result).not_to be(nil)
    expect(result).to be_instance_of(described_class)
    expect(image).not_to be(result)

    expect { image.opaque_channel('red', 'blue', true) }.not_to raise_error
    expect { image.opaque_channel('red', 'blue', true, 50) }.not_to raise_error
    expect { image.opaque_channel('red', 'blue', true, 50, Magick::RedChannel) }.not_to raise_error
    expect { image.opaque_channel('red', 'blue', true, 50, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error
    expect do
      image.opaque_channel('red', 'blue', true, 50, Magick::RedChannel, Magick::GreenChannel, Magick::BlueChannel)
    end.not_to raise_error

    expect { image.opaque_channel('red', 'blue', true, 50, 50) }.to raise_error(TypeError)
    expect { image.opaque_channel('red', 'blue', true, []) }.to raise_error(TypeError)
    expect { image.opaque_channel('red') }.to raise_error(ArgumentError)
    expect { image.opaque_channel('red', 'blue', true, -0.1) }.to raise_error(ArgumentError)
    expect { image.opaque_channel('red', []) }.to raise_error(TypeError)
  end
end

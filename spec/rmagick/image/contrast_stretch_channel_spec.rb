RSpec.describe Magick::Image, '#contrast_stretch_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.contrast_stretch_channel(25)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.contrast_stretch_channel(25, 50) }.not_to raise_error
    expect { image.contrast_stretch_channel('10%') }.not_to raise_error
    expect { image.contrast_stretch_channel('10%', '50%') }.not_to raise_error
    expect { image.contrast_stretch_channel(25, 50, Magick::RedChannel) }.not_to raise_error
    expect { image.contrast_stretch_channel(25, 50, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error
    expect { image.contrast_stretch_channel(25, 50, 'x') }.to raise_error(TypeError)
    expect { image.contrast_stretch_channel }.to raise_error(ArgumentError)
    expect { image.contrast_stretch_channel('x') }.to raise_error(ArgumentError)
    expect { image.contrast_stretch_channel(25, 'x') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Image, '#sigmoidal_contrast_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.sigmoidal_contrast_channel
    expect(res).to be_instance_of(described_class)

    expect { image.sigmoidal_contrast_channel(3.0) }.not_to raise_error
    expect { image.sigmoidal_contrast_channel(3.0, 50.0) }.not_to raise_error
    expect { image.sigmoidal_contrast_channel(3.0, 50.0, true) }.not_to raise_error
    expect { image.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel) }.not_to raise_error
    expect { image.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel, 2) }.to raise_error(TypeError)
    expect { image.sigmoidal_contrast_channel('x') }.to raise_error(TypeError)
    expect { image.sigmoidal_contrast_channel(3.0, 'x') }.to raise_error(TypeError)
  end
end

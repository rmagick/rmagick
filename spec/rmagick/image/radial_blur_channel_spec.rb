RSpec.describe Magick::Image, '#radial_blur_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.radial_blur_channel(30)
    expect(res).not_to be(nil)
    expect(res).to be_instance_of(described_class)

    expect { image.radial_blur_channel(30, Magick::RedChannel) }.not_to raise_error
    expect { image.radial_blur_channel(30, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error

    expect { image.radial_blur_channel }.to raise_error(ArgumentError)
    expect { image.radial_blur_channel(30, 2) }.to raise_error(TypeError)
  end
end

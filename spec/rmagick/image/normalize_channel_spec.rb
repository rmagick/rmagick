RSpec.describe Magick::Image, '#normalize_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.normalize_channel
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.normalize_channel(Magick::RedChannel) }.not_to raise_error
    expect { image.normalize_channel(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.normalize_channel(Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end

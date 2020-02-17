RSpec.describe Magick::Image, "#adaptive_blur_channel" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.adaptive_blur_channel
    expect(result).to be_instance_of(described_class)

    expect { image.adaptive_blur_channel(2) }.not_to raise_error
    expect { image.adaptive_blur_channel(3, 2) }.not_to raise_error
    expect { image.adaptive_blur_channel(3, 2, Magick::RedChannel) }.not_to raise_error
    expect { image.adaptive_blur_channel(3, 2, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.adaptive_blur_channel(3, 2, 2) }.to raise_error(TypeError)
  end
end

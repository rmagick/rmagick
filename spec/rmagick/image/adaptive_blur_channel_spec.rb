RSpec.describe Magick::Image, "#adaptive_blur_channel" do
  it "works" do
    img = described_class.new(20, 20)

    expect do
      res = img.adaptive_blur_channel
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { img.adaptive_blur_channel(2) }.not_to raise_error
    expect { img.adaptive_blur_channel(3, 2) }.not_to raise_error
    expect { img.adaptive_blur_channel(3, 2, Magick::RedChannel) }.not_to raise_error
    expect { img.adaptive_blur_channel(3, 2, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img.adaptive_blur_channel(3, 2, 2) }.to raise_error(TypeError)
  end
end

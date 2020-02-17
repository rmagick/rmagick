RSpec.describe Magick::Image, "#blur_channel" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.blur_channel }.not_to raise_error
    expect { image.blur_channel(1) }.not_to raise_error
    expect { image.blur_channel(1, 2) }.not_to raise_error
    expect { image.blur_channel(1, 2, Magick::RedChannel) }.not_to raise_error
    expect { image.blur_channel(1, 2, Magick::RedChannel, Magick::BlueChannel, Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { image.blur_channel(1, 2, Magick::CyanChannel, Magick::MagentaChannel, Magick::YellowChannel, Magick::BlackChannel) }.not_to raise_error
    expect { image.blur_channel(1, 2, Magick::GrayChannel) }.not_to raise_error
    expect { image.blur_channel(1, 2, Magick::AllChannels) }.not_to raise_error
    expect { image.blur_channel(1, 2, 2) }.to raise_error(TypeError)
    res = image.blur_channel
    expect(res).to be_instance_of(described_class)
  end
end

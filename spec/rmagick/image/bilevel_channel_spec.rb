RSpec.describe Magick::Image, "#bilevel_channel" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.bilevel_channel }.to raise_error(ArgumentError)
    expect { image.bilevel_channel(100) }.not_to raise_error
    expect { image.bilevel_channel(100, Magick::RedChannel) }.not_to raise_error
    expect { image.bilevel_channel(100, Magick::RedChannel, Magick::BlueChannel, Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { image.bilevel_channel(100, Magick::CyanChannel, Magick::MagentaChannel, Magick::YellowChannel, Magick::BlackChannel) }.not_to raise_error
    expect { image.bilevel_channel(100, Magick::GrayChannel) }.not_to raise_error
    expect { image.bilevel_channel(100, Magick::AllChannels) }.not_to raise_error
    expect { image.bilevel_channel(100, 2) }.to raise_error(TypeError)
    result = image.bilevel_channel(100)
    expect(result).to be_instance_of(described_class)
  end
end

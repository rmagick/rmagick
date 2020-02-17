RSpec.describe Magick::Image, "#channel_mean" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.channel_mean
    expect(result).to be_instance_of(Array)
    expect(result.length).to eq(2)
    expect(result[0]).to be_instance_of(Float)
    expect(result[1]).to be_instance_of(Float)

    expect { image.channel_mean(Magick::RedChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::MagentaChannel, Magick::CyanChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::CyanChannel, Magick::BlackChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::GrayChannel) }.not_to raise_error
    expect { image.channel_mean(2) }.to raise_error(TypeError)
  end
end

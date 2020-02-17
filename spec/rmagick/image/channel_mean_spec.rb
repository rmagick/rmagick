RSpec.describe Magick::Image, "#channel_mean" do
  it "works" do
    image = described_class.new(20, 20)

    res = image.channel_mean
    expect(res).to be_instance_of(Array)
    expect(res.length).to eq(2)
    expect(res[0]).to be_instance_of(Float)
    expect(res[1]).to be_instance_of(Float)

    expect { image.channel_mean(Magick::RedChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::MagentaChannel, Magick::CyanChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::CyanChannel, Magick::BlackChannel) }.not_to raise_error
    expect { image.channel_mean(Magick::GrayChannel) }.not_to raise_error
    expect { image.channel_mean(2) }.to raise_error(TypeError)
  end
end

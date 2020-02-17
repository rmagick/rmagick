RSpec.describe Magick::Image, "#channel_extrema" do
  it "works" do
    img = described_class.new(20, 20)

    res = img.channel_extrema
    expect(res).to be_instance_of(Array)
    expect(res.length).to eq(2)
    expect(res[0]).to be_kind_of(Integer)
    expect(res[1]).to be_kind_of(Integer)

    expect { img.channel_extrema(Magick::RedChannel) }.not_to raise_error
    expect { img.channel_extrema(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img.channel_extrema(Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { img.channel_extrema(Magick::MagentaChannel, Magick::CyanChannel) }.not_to raise_error
    expect { img.channel_extrema(Magick::CyanChannel, Magick::BlackChannel) }.not_to raise_error
    expect { img.channel_extrema(Magick::GrayChannel) }.not_to raise_error
    expect { img.channel_extrema(2) }.to raise_error(TypeError)
  end
end

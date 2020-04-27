RSpec.describe Magick::Image, "#channel_extrema" do
  it "returns the min and max intensity values for all channels when no arguments are passed" do
    image = build_image

    extrema = image.channel_extrema

    expect(extrema).to eq([2, 247])
  end

  it "returns the min and max intensity values for one channel" do
    image = build_image

    extrema = image.channel_extrema(Magick::GreenChannel)

    expect(extrema).to eq([65, 236])
  end

  it "returns the min and max intensity values for two channels" do
    image = build_image

    extrema = image.channel_extrema(Magick::RedChannel, Magick::GreenChannel)

    expect(extrema).to eq([8, 239])
  end

  it "returns the min and max intensity values for three channels" do
    image = build_image

    extrema = image.channel_extrema(Magick::RedChannel, Magick::GreenChannel, Magick::BlueChannel)

    expect(extrema).to eq([2, 247])
  end

  it "raises an error when the wrong type of argument is passed" do
    image = build_image

    expect { image.channel_extrema("test") }
      .to raise_error(TypeError, "argument must be a ChannelType value (String given)")
  end
end

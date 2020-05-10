RSpec.describe Magick::Image, "#channel_depth" do
  it "returns the depth for the given channel" do
    image = build_image

    depth = image.channel_depth(Magick::RedChannel)

    expect(depth).to eq(16)
  end

  it "returns the depth for all channels when no arguments are passed" do
    image = build_image

    depth = image.channel_depth

    expect(depth).to eq(16)
  end

  it "raises an error when the wrong type of argument is passed" do
    image = build_image

    expect { image.channel_depth("test") }
      .to raise_error(TypeError, "argument must be a ChannelType value (String given)")
  end
end

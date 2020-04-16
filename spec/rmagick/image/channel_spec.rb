RSpec.describe Magick::Image, "#channel" do
  it "returns a gray image based on the red pixel values" do
    image = build_image
    expected_pixels = [gray(45), gray(209), gray(239), gray(8)]

    expect(image.channel(Magick::RedChannel)).to match_pixels(expected_pixels)
  end

  it "returns a gray image based on the green pixel values" do
    image = build_image
    expected_pixels = [gray(98), gray(171), gray(236), gray(65)]

    expect(image.channel(Magick::GreenChannel)).to match_pixels(expected_pixels)
  end

  it "returns a gray image based on the blue pixel values" do
    image = build_image
    expected_pixels = [gray(156), gray(11), gray(2), gray(247)]

    expect(image.channel(Magick::BlueChannel)).to match_pixels(expected_pixels)
  end

  it "returns a gray image based on the cyan pixel values from a CMYK image" do
    image = build_image(mode: "CMYK")
    expected_pixels = [gray(23), gray(29), gray(239), gray(84)]

    expect(image.channel(Magick::CyanChannel)).to match_pixels(expected_pixels)
  end

  it "returns a gray image based on the magenta pixel values from a CMYK image" do
    image = build_image(mode: "CMYK")
    expected_pixels = [gray(54), gray(71), gray(206), gray(165)]

    expect(image.channel(Magick::MagentaChannel)).to match_pixels(expected_pixels)
  end

  it "returns a gray image based on the yellow pixel values from a CMYK image" do
    image = build_image(mode: "CMYK")
    expected_pixels = [gray(186), gray(131), gray(99), gray(47)]

    expect(image.channel(Magick::YellowChannel)).to match_pixels(expected_pixels)
  end

  it "returns a gray image based on the black pixel values from a CMYK image", unsupported_before('6.8') do
    image = build_image(mode: "CMYK")
    expected_pixels = [gray(76), gray(122), gray(76), gray(54)]

    expect(image.channel(Magick::BlackChannel)).to match_pixels(expected_pixels)
  end

  it "raises an error when no arguments are passed" do
    image = build_image

    expect { image.channel }
      .to raise_error(ArgumentError, "wrong number of arguments (given 0, expected 1)")
  end

  it "raises an error when two channels are passed" do
    image = build_image

    expect { image.channel(Magick::BlackChannel, Magick::RedChannel) }
      .to raise_error(ArgumentError, "wrong number of arguments (given 2, expected 1)")
  end

  it "raises an error when the wrong type of argument is passed" do
    image = build_image

    expect { image.channel("blue") }
      .to raise_error(TypeError, "wrong enumeration type - expected Magick::ChannelType, got String")
  end

  Magick::ChannelType.values.each do |channel|
    it "works with #{channel}" do
      image = build_image

      expect { image.channel(channel) }.not_to raise_error
    end
  end
end

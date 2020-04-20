RSpec.describe Magick::Image, "#channel_mean" do
  it "returns the mean and std. dev for the RedChannel" do
    image = build_image

    mean_and_stddev = image.channel_mean(Magick::RedChannel)
    expected_stddev = value_by_version(
      "6.7": 100.1757830016816,
      "6.8": 100.1757830016816,
      "6.9": 115.6730305646048,
      "7.0": 115.6730305646048
    )

    expect(mean_and_stddev).to eq([125.25, expected_stddev])
  end

  it "returns the mean and std. dev for the GreenChannel" do
    image = build_image

    mean_and_stddev = image.channel_mean(Magick::GreenChannel)
    expected_stddev = value_by_version(
      "6.7": 66.22122016393234,
      "6.8": 66.22122016393234,
      "6.9": 76.46567857542362,
      "7.0": 76.46567857542362
    )

    expect(mean_and_stddev).to eq([142.5, expected_stddev])
  end

  it "returns the mean and std. dev for the RedChannel and GreenChannel" do
    image = build_image

    mean_and_stddev = image.channel_mean(Magick::RedChannel, Magick::GreenChannel)
    expected_stddev = value_by_version(
      "6.7": 84.91300695417634,
      "6.8": 84.91300695417634,
      "6.9": 96.06935457001421,
      "7.0": 96.06935457001421
    )

    expect(mean_and_stddev).to eq([133.875, expected_stddev])
  end

  it "returns the mean and std. dev for all channels when no arguments are passed" do
    image = build_image

    mean_and_stddev = image.channel_mean
    expected_stddev = value_by_version(
      "6.7": 91.23584365076407,
      "6.8": 91.23584365076407,
      "6.9": 103.58337316538109,
      "7.0": 103.58337316538109
    )

    expect(mean_and_stddev).to eq([123.91666666666667, expected_stddev])
  end

  it "raises an error when the wrong type of argument is passed" do
    image = build_image

    expect { image.channel_mean("blue") }
      .to raise_error(TypeError, "argument must be a ChannelType value (String given)")
  end
end

# frozen_string_literal: true

RSpec.describe Magick::Image, "#channel_mean" do
  it "returns the mean and std. dev for the RedChannel" do
    image = build_image

    mean_and_stddev = image.channel_mean(Magick::RedChannel)

    expect(mean_and_stddev[0]).to be_within(0.0000001).of(125.25)
    expect(mean_and_stddev[1]).to be_within(0.0000001).of(115.6730305646048)
  end

  it "returns the mean and std. dev for the GreenChannel" do
    image = build_image

    mean_and_stddev = image.channel_mean(Magick::GreenChannel)

    expect(mean_and_stddev[0]).to be_within(0.0000001).of(142.5)
    expect(mean_and_stddev[1]).to be_within(0.0000001).of(76.46567857542362)
  end

  it "returns the mean and std. dev for the RedChannel and GreenChannel" do
    image = build_image

    mean_and_stddev = image.channel_mean(Magick::RedChannel, Magick::GreenChannel)

    expect(mean_and_stddev[0]).to be_within(0.0000001).of(133.875)
    expect(mean_and_stddev[1]).to be_within(0.0000001).of(96.06935457001421)
  end

  it "returns the mean and std. dev for all channels when no arguments are passed" do
    image = build_image

    mean_and_stddev = image.channel_mean

    expect(mean_and_stddev[0]).to be_within(0.0000001).of(123.91666666666667)
    expect(mean_and_stddev[1]).to be_within(0.0000001).of(103.58337316538109)
  end

  it "raises an error when the wrong type of argument is passed" do
    image = build_image

    expect { image.channel_mean("blue") }
      .to raise_error(TypeError, "argument must be a ChannelType value (String given)")
  end
end

# frozen_string_literal: true

RSpec.describe Magick::Image, '#chromaticity' do
  it "returns an assigned chromaticity" do
    image = build_image

    red_primary = Magick::Primary.new(70, 200, 0)
    green_primary = Magick::Primary.new(200, 44, 0)
    blue_primary = Magick::Primary.new(60, 22, 0)
    white_point = Magick::Primary.new(77, 43, 0)
    chromaticity = Magick::Chromaticity.new(red_primary, green_primary, blue_primary, white_point)
    image.chromaticity = chromaticity

    expect(image.chromaticity.red_primary).to eq(red_primary)
    expect(image.chromaticity.green_primary).to eq(green_primary)
    expect(image.chromaticity.blue_primary).to eq(blue_primary)
    expect(image.chromaticity.white_point).to eq(white_point)
  end

  it "returns default chromaticity values" do
    image = build_image
    delta = 0.0001

    expect(image.chromaticity.red_primary).to have_attributes(
      x: be_within(delta).of(0.64),
      y: be_within(delta).of(0.33),
      z: be_within(delta).of(0.03)
    )

    expect(image.chromaticity.green_primary).to have_attributes(
      x: be_within(delta).of(0.30),
      y: be_within(delta).of(0.60),
      z: be_within(delta).of(0.10)
    )

    expect(image.chromaticity.blue_primary).to have_attributes(
      x: be_within(delta).of(0.15),
      y: be_within(delta).of(0.06),
      z: be_within(delta).of(0.79)
    )

    expect(image.chromaticity.white_point).to have_attributes(
      x: be_within(delta).of(0.3127),
      y: be_within(delta).of(0.3290),
      z: be_within(delta).of(0.3583)
    )
  end
end

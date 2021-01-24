RSpec.describe Magick::Image, '#chromaticity=' do
  it "allows setting the chromaticity" do
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

  it "sets the z values to 0" do
    image = build_image

    chromaticity = Magick::Chromaticity.new(
      Magick::Primary.new(70, 200, 50),
      Magick::Primary.new(200, 44, 33),
      Magick::Primary.new(60, 22, 1),
      Magick::Primary.new(77, 43, 122)
    )
    image.chromaticity = chromaticity

    expected_red_primary = Magick::Primary.new(70, 200, 0)
    expected_green_primary = Magick::Primary.new(200, 44, 0)
    expected_blue_primary = Magick::Primary.new(60, 22, 0)
    expected_white_point = Magick::Primary.new(77, 43, 0)
    expect(image.chromaticity.red_primary).to eq(expected_red_primary)
    expect(image.chromaticity.green_primary).to eq(expected_green_primary)
    expect(image.chromaticity.blue_primary).to eq(expected_blue_primary)
    expect(image.chromaticity.white_point).to eq(expected_white_point)
  end
end

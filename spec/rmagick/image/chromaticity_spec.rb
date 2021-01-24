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

    red_primary = Magick::Primary.new(0.6399999856948853, 0.33000001311302185, 0.029999999329447746)
    green_primary = Magick::Primary.new(0.30000001192092896, 0.6000000238418579, 0.10000000149011612)
    blue_primary = Magick::Primary.new(0.15000000596046448, 0.05999999865889549, 0.7900000214576721)
    white_point = Magick::Primary.new(0.3127000033855438, 0.32899999618530273, 0.35830000042915344)

    expect(image.chromaticity.red_primary).to eq(red_primary)
    expect(image.chromaticity.green_primary).to eq(green_primary)
    expect(image.chromaticity.blue_primary).to eq(blue_primary)
    expect(image.chromaticity.white_point).to eq(white_point)
  end
end

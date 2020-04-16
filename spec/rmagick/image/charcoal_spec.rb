RSpec.describe Magick::Image, "#charcoal" do
  it "applies a charcoal effect", unsupported_before('6.8') do
    image = build_image
    expected_pixels = [gray(53736), gray(48703), gray(9953), gray(51857)]

    expect(image.charcoal).to match_pixels(expected_pixels, delta: 1)
  end

  it "applies a charcoal effect with radius", unsupported_before('6.8') do
    image = build_image
    expected_pixels = [gray(55422), gray(49372), gray(9121), gray(53918)]

    expect(image.charcoal(1.0)).to match_pixels(expected_pixels, delta: 50)
  end

  it "applies a charcoal effect with radius and sigma", unsupported_before('6.8') do
    image = build_image
    expected_pixels = [gray(51460), gray(48203), gray(11918), gray(50352)]

    expect(image.charcoal(1.0, 2.0)).to match_pixels(expected_pixels, delta: 100)
  end

  it "raises an error with an incorrect number of arguments" do
    image = build_image

    expect { image.charcoal(1.0, 2.0, 3.0) }
      .to raise_error(ArgumentError, "wrong number of arguments (3 for 0 to 2)")
  end
end

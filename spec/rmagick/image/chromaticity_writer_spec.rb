# frozen_string_literal: true

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

  it "raises TypeError when Chromaticity#values does not return an Array" do
    image = build_image
    primary = Magick::Primary.new(0, 0, 0)
    chromaticity = Magick::Chromaticity.new(primary, primary, primary, primary)
    allow_any_instance_of(Magick::Chromaticity).to receive(:values).and_return(1) # rubocop:disable RSpec/AnyInstance

    expect { image.chromaticity = chromaticity }
      .to raise_error(TypeError, "Magick::Chromaticity#values must return an Array (Integer given)")
  end

  it "raises TypeError when Primary#values does not return an Array" do
    image = build_image
    primary = Magick::Primary.new(0, 0, 0)
    white_point = Magick::Primary.new(0, 0, 0)
    allow(white_point).to receive(:values).and_return({})
    chromaticity = Magick::Chromaticity.new(primary, primary, primary, white_point)

    expect { image.chromaticity = chromaticity }
      .to raise_error(TypeError, "Magick::Primary#values must return an Array (Hash given)")
  end

  it "raises TypeError when a member is not a Primary" do
    image = build_image
    primary = Magick::Primary.new(0, 0, 0)

    chromaticity = Magick::Chromaticity.new(primary, { x: 0.6, y: 0.3 }, primary, primary)
    expect { image.chromaticity = chromaticity }.to raise_error(TypeError, "type mismatch: Hash given")

    chromaticity = Magick::Chromaticity.new(primary, primary, primary, nil)
    expect { image.chromaticity = chromaticity }.to raise_error(TypeError, "type mismatch: NilClass given")
  end

  it "accepts a subclass of Primary and a Primary that has a singleton method" do
    image = build_image
    primary = Magick::Primary.new(0, 0, 0)
    red_primary = Class.new(Magick::Primary).new(70, 200, 0)
    green_primary = Magick::Primary.new(200, 44, 0)
    green_primary.define_singleton_method(:label) { "green" }
    image.chromaticity = Magick::Chromaticity.new(red_primary, green_primary, primary, primary)

    expect(image.chromaticity.red_primary).to eq(Magick::Primary.new(70, 200, 0))
    expect(image.chromaticity.green_primary).to eq(Magick::Primary.new(200, 44, 0))
  end
end

RSpec.describe Magick::Image, "#chop" do
  def build_gray_image
    image = Magick::Image.new(3, 3)
    pixels = [
      [gray(1), gray(2), gray(3)],
      [gray(4), gray(5), gray(6)],
      [gray(7), gray(8), gray(9)]
    ]
    image.import_pixels(0, 0, 3, 3, "RGB", pixels.flatten)
  end

  it "removes a cross from the middle of the image" do
    image = build_gray_image

    new_image = image.chop(1, 1, 1, 1)

    expected_pixels = [
      [gray(1), gray(3)],
      [gray(7), gray(9)]
    ]
    expect(new_image).to match_pixels(expected_pixels)
  end

  it "removes an L-shape from the bottom left of the image" do
    image = build_gray_image

    new_image = image.chop(0, 2, 1, 1)

    expected_pixels = [
      [gray(2), gray(3)],
      [gray(5), gray(6)]
    ]
    expect(new_image).to match_pixels(expected_pixels)
  end

  it "removes 1 column from the middle of the image" do
    image = build_gray_image

    new_image = image.chop(1, 1, 1, 0)

    expected_pixels = [
      [gray(1), gray(3)],
      [gray(4), gray(6)],
      [gray(7), gray(9)]
    ]
    expect(new_image).to match_pixels(expected_pixels)
  end

  it "removes 1 row from the middle of the image" do
    image = build_gray_image

    new_image = image.chop(1, 1, 0, 1)

    expected_pixels = [
      [gray(1), gray(2), gray(3)],
      [gray(7), gray(8), gray(9)]
    ]
    expect(new_image).to match_pixels(expected_pixels)
  end

  it "removes 2 rows and 2 columns from the image" do
    image = build_gray_image

    new_image = image.chop(0, 0, 2, 2)

    expect(new_image).to match_pixels([gray(9)])
  end

  it "raises an error when x is out of bounds" do
    image = build_gray_image

    expect { image.chop(5, 1, 1, 1) }.to raise_error(RuntimeError)
  end

  it "raises an error when y is out of bounds" do
    image = build_gray_image

    expect { image.chop(1, 5, 1, 1) }.to raise_error(RuntimeError)
  end

  it "does not raise an error when width or height are out of bounds" do
    image = build_gray_image

    expect { image.chop(1, 1, 5, 5) }.not_to raise_error
  end

  it "raises an error when the argument is the wrong type" do
    image = build_gray_image

    expect { image.chop("hello", 1, 1, 1) }.to raise_error(TypeError)
  end
end

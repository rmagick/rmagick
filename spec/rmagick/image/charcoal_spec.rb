RSpec.describe Magick::Image, "#charcoal" do
  def expect_im_version(hash)
    im_major_minor = Magick::IMAGEMAGICK_VERSION.split('.').take(2).join('.')

    hash.each do |key, value|
      return value if key == im_major_minor
      return value if key.is_a?(Range) && key.include?(im_major_minor)
    end

    raise ArgumentError, "no value specified for version: #{im_major_minor}"
  end

  it "works" do
    image = described_class.new(20, 20)

    result = image.charcoal
    expect(result).to be_instance_of(described_class)

    expect { image.charcoal(1.0) }.not_to raise_error
    expect { image.charcoal(1.0, 2.0) }.not_to raise_error
    expect { image.charcoal(1.0, 2.0, 3.0) }.to raise_error(ArgumentError)
  end

  it "applies a charcoal effect" do
    pixels = [45, 98, 156, 209, 171, 11, 239, 236, 2, 8, 65, 247]

    image = described_class.new(2, 2)
    image.import_pixels(0, 0, 2, 2, "RGB", pixels)

    new_image = image.charcoal

    new_pixels = new_image.export_pixels(0, 0, 2, 2, "RGB")
    expected_pixels = expect_im_version(
      '6.7' => [65535, 65535, 65535, 0, 0, 0, 0, 0, 0, 65535, 65535, 65535],
      ('6.8'..'7.0') => [53736, 53736, 53736, 48703, 48703, 48703, 9953, 9953, 9953, 51857, 51857, 51857]
    )

    expect(new_pixels).to match_pixels(expected_pixels, delta: 1)
  end
end

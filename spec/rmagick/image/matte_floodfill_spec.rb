RSpec.describe Magick::Image, '#matte_floodfill' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.matte_floodfill(image.columns / 2, image.rows / 2)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.matte_floodfill(image.columns, image.rows) }.not_to raise_error

    Magick::PaintMethod.values do |method|
      next if [Magick::FillToBorderMethod, Magick::FloodfillMethod].include?(method)

      expect { image.matte_flood_fill('blue', Magick::TransparentAlpha, image.columns, image.rows, method) }.to raise_error(ArgumentError)
    end
    expect { image.matte_floodfill(image.columns + 1, image.rows) }.to raise_error(ArgumentError)
    expect { image.matte_floodfill(image.columns, image.rows + 1) }.to raise_error(ArgumentError)
    expect { image.matte_flood_fill('blue', image.columns, image.rows, Magick::FloodfillMethod, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.matte_flood_fill('blue', image.columns, image.rows, Magick::FloodfillMethod, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
  end
end

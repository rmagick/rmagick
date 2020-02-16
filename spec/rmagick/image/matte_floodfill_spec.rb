RSpec.describe Magick::Image, '#matte_floodfill' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.matte_floodfill(img.columns / 2, img.rows / 2)
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end.not_to raise_error
    expect { img.matte_floodfill(img.columns, img.rows) }.not_to raise_error

    Magick::PaintMethod.values do |method|
      next if [Magick::FillToBorderMethod, Magick::FloodfillMethod].include?(method)

      expect { img.matte_flood_fill('blue', Magick::TransparentAlpha, img.columns, img.rows, method) }.to raise_error(ArgumentError)
    end
    expect { img.matte_floodfill(img.columns + 1, img.rows) }.to raise_error(ArgumentError)
    expect { img.matte_floodfill(img.columns, img.rows + 1) }.to raise_error(ArgumentError)
    expect { img.matte_flood_fill('blue', img.columns, img.rows, Magick::FloodfillMethod, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { img.matte_flood_fill('blue', img.columns, img.rows, Magick::FloodfillMethod, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
  end
end

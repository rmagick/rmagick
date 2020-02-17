RSpec.describe Magick::Image, '#texture_fill_to_border' do
  it 'works' do
    img = described_class.new(20, 20)
    texture = described_class.read('granite:').first

    res = img.texture_fill_to_border(img.columns / 2, img.rows / 2, texture)
    expect(res).to be_instance_of(described_class)

    expect { img.texture_fill_to_border(img.columns / 2, img.rows / 2, 'x') }.to raise_error(NoMethodError)
    expect { img.texture_fill_to_border(img.columns * 2, img.rows, texture) }.to raise_error(ArgumentError)
    expect { img.texture_fill_to_border(img.columns, img.rows * 2, texture) }.to raise_error(ArgumentError)

    Magick::PaintMethod.values do |method|
      next if [Magick::FillToBorderMethod, Magick::FloodfillMethod].include?(method)

      expect { img.texture_flood_fill('blue', texture, img.columns, img.rows, method) }.to raise_error(ArgumentError)
    end
  end
end

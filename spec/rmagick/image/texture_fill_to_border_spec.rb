RSpec.describe Magick::Image, '#texture_fill_to_border' do
  it 'works' do
    image = described_class.new(20, 20)
    texture = described_class.read('granite:').first

    result = image.texture_fill_to_border(image.columns / 2, image.rows / 2, texture)
    expect(result).to be_instance_of(described_class)

    expect { image.texture_fill_to_border(image.columns / 2, image.rows / 2, 'x') }.to raise_error(NoMethodError)
    expect { image.texture_fill_to_border(image.columns * 2, image.rows, texture) }.to raise_error(ArgumentError)
    expect { image.texture_fill_to_border(image.columns, image.rows * 2, texture) }.to raise_error(ArgumentError)

    Magick::PaintMethod.values do |method|
      next if [Magick::FillToBorderMethod, Magick::FloodfillMethod].include?(method)

      expect { image.texture_flood_fill('blue', texture, image.columns, image.rows, method) }.to raise_error(ArgumentError)
    end
  end
end

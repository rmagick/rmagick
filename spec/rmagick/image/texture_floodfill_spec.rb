RSpec.describe Magick::Image, '#texture_floodfill' do
  it 'works' do
    image = described_class.new(20, 20)
    texture = described_class.read('granite:').first

    res = image.texture_floodfill(image.columns / 2, image.rows / 2, texture)
    expect(res).to be_instance_of(described_class)

    expect { image.texture_floodfill(image.columns / 2, image.rows / 2, 'x') }.to raise_error(NoMethodError)
    texture.destroy!
    expect { image.texture_floodfill(image.columns / 2, image.rows / 2, texture) }.to raise_error(Magick::DestroyedImageError)
  end
end

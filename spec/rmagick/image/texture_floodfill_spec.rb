RSpec.describe Magick::Image, '#texture_floodfill' do
  it 'works' do
    image = described_class.new(20, 20)
    texture = described_class.read('granite:').first

    result = image.texture_floodfill(image.columns / 2, image.rows / 2, texture)
    expect(result).to be_instance_of(described_class)

    expect { image.texture_floodfill(image.columns / 2, image.rows / 2, 'x') }.to raise_error(NoMethodError)
    texture.destroy!
    expect { image.texture_floodfill(image.columns / 2, image.rows / 2, texture) }.to raise_error(Magick::DestroyedImageError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.texture_floodfill(image.columns / 2, image.rows / 2, image_list) }.not_to raise_error
  end
end

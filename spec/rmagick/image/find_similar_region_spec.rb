RSpec.describe Magick::Image, '#find_similar_region' do
  it 'works' do
    image = described_class.new(20, 20)
    girl = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    region = girl.crop(10, 10, 50, 50)

    x, y = girl.find_similar_region(region)
    expect(x).not_to be(nil)
    expect(y).not_to be(nil)
    expect(x).to eq(10)
    expect(y).to eq(10)

    x, y = girl.find_similar_region(region, 0)
    expect(x).to eq(10)
    expect(y).to eq(10)

    x, y = girl.find_similar_region(region, 0, 0)
    expect(x).to eq(10)
    expect(y).to eq(10)

    image_list = Magick::ImageList.new
    image_list << region

    x, y = girl.find_similar_region(image_list, 0, 0)
    expect(x).to eq(10)
    expect(y).to eq(10)

    x = girl.find_similar_region(image)
    expect(x).to be(nil)

    expect { girl.find_similar_region(region, 10, 10, 10) }.to raise_error(ArgumentError)
    expect { girl.find_similar_region(region, 10, 'x') }.to raise_error(TypeError)
    expect { girl.find_similar_region(region, 'x') }.to raise_error(TypeError)

    region.destroy!
    expect { girl.find_similar_region(region) }.to raise_error(Magick::DestroyedImageError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.find_similar_region(image_list) }.not_to raise_error
    expect { image.find_similar_region(image_list, 0) }.not_to raise_error
    expect { image.find_similar_region(image_list, 0, 0) }.not_to raise_error
  end
end

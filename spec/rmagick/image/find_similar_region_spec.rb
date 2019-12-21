RSpec.describe Magick::Image, '#find_similar_region' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    girl = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    region = girl.crop(10, 10, 50, 50)
    expect do
      x, y = girl.find_similar_region(region)
      expect(x).not_to be(nil)
      expect(y).not_to be(nil)
      expect(x).to eq(10)
      expect(y).to eq(10)
    end.not_to raise_error
    expect do
      x, y = girl.find_similar_region(region, 0)
      expect(x).to eq(10)
      expect(y).to eq(10)
    end.not_to raise_error
    expect do
      x, y = girl.find_similar_region(region, 0, 0)
      expect(x).to eq(10)
      expect(y).to eq(10)
    end.not_to raise_error

    list = Magick::ImageList.new
    list << region
    expect do
      x, y = girl.find_similar_region(list, 0, 0)
      expect(x).to eq(10)
      expect(y).to eq(10)
    end.not_to raise_error

    x = girl.find_similar_region(@img)
    expect(x).to be(nil)

    expect { girl.find_similar_region(region, 10, 10, 10) }.to raise_error(ArgumentError)
    expect { girl.find_similar_region(region, 10, 'x') }.to raise_error(TypeError)
    expect { girl.find_similar_region(region, 'x') }.to raise_error(TypeError)

    region.destroy!
    expect { girl.find_similar_region(region) }.to raise_error(Magick::DestroyedImageError)
  end
end

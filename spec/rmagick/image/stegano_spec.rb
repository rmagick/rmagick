RSpec.describe Magick::Image, '#stegano' do
  it 'works' do
    image = described_class.new(100, 100) { self.background_color = 'black' }
    watermark = described_class.new(10, 10) { self.background_color = 'white' }

    result = image.stegano(watermark, 0)
    expect(result).to be_instance_of(described_class)

    watermark.destroy!
    expect { image.stegano(watermark, 0) }.to raise_error(Magick::DestroyedImageError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.stegano(image_list, 0) }.not_to raise_error
  end
end

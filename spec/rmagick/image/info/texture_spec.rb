RSpec.describe Magick::Image::Info, '#texture' do
  it 'works' do
    info = described_class.new
    image = Magick::Image.read('granite:') { self.size = '20x20' }

    expect { info.texture = image.first }.not_to raise_error
    expect { info.texture = nil }.not_to raise_error
  end

  it 'accepts an ImageList argument' do
    info = described_class.new
    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)

    expect { info.texture = image_list }.not_to raise_error
  end
end

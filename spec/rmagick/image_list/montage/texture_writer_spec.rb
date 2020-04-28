RSpec.describe Magick::ImageList::Montage, '#texture=' do
  it 'works' do
    montage = described_class.new
    image = Magick::Image.new(10, 10)

    expect { montage.texture = image }.not_to raise_error
  end

  it 'accepts an ImageList argument' do
    montage = described_class.new

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)

    expect { montage.texture = image_list }.not_to raise_error
  end
end

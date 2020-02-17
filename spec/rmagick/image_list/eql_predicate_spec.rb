RSpec.describe Magick::ImageList, '#eql?' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list2 = image_list
    expect(image_list.eql?(image_list2)).to be(true)
    image_list2 = image_list.copy
    expect(image_list.eql?(image_list2)).to be(false)
  end
end

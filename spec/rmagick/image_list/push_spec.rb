RSpec.describe Magick::ImageList, '#push' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list = image_list
    image1 = image_list[0]
    image2 = image_list[1]
    image_list2 = nil
    expect { image_list2 = image_list.push(image1, image2) }.not_to raise_error
    expect(image_list).to be(image_list2) # push returns self
    expect(image_list.cur_image).to be(image2)
  end
end

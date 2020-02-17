RSpec.describe Magick::ImageList, '#push' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list = list
    image1 = list[0]
    image2 = list[1]
    list2 = nil
    expect { list2 = list.push(image1, image2) }.not_to raise_error
    expect(list).to be(list2) # push returns self
    expect(list.cur_image).to be(image2)
  end
end

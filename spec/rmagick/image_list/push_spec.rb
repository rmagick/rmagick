RSpec.describe Magick::ImageList, '#push' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list = list
    img1 = list[0]
    img2 = list[1]
    list2 = nil
    expect { list2 = list.push(img1, img2) }.not_to raise_error
    expect(list).to be(list2) # push returns self
    expect(list.cur_image).to be(img2)
  end
end

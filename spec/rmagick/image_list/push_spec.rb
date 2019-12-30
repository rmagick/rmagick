RSpec.describe Magick::ImageList, '#push' do
  before do
    @list = Magick::ImageList.new(*FILES[0..9])
    @list2 = Magick::ImageList.new # intersection is 5..9
    @list2 << @list[5]
    @list2 << @list[6]
    @list2 << @list[7]
    @list2 << @list[8]
    @list2 << @list[9]
  end

  it 'works' do
    list = @list
    img1 = @list[0]
    img2 = @list[1]
    expect { @list.push(img1, img2) }.not_to raise_error
    expect(@list).to be(list) # push returns self
    expect(@list.cur_image).to be(img2)
  end
end

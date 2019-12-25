RSpec.describe Magick::ImageList, '#reverse!' do
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
    cur = @list.cur_image
    expect { @list.reverse! }.not_to raise_error
    expect(@list).to be(list)
    expect(@list.cur_image).to be(cur)
  end
end

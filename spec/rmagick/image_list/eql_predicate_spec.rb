RSpec.describe Magick::ImageList, '#eql?' do
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
    list2 = @list
    expect(@list.eql?(list2)).to be(true)
    list2 = @list.copy
    expect(@list.eql?(list2)).to be(false)
  end
end

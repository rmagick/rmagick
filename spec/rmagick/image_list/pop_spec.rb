RSpec.describe Magick::ImageList, '#pop' do
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
    @list.scene = 8
    cur = @list.cur_image
    last = @list[-1]
    expect do
      expect(@list.pop).to be(last)
      expect(@list.cur_image).to be(cur)
    end.not_to raise_error

    expect(@list.pop).to be(cur)
    expect(@list.cur_image).to be(@list[-1])
  end
end

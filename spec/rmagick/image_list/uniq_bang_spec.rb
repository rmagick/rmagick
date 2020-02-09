RSpec.describe Magick::ImageList, '#uniq!' do
  before do
    @list = described_class.new(*FILES[0..9])
    @list2 = described_class.new # intersection is 5..9
    @list2 << @list[5]
    @list2 << @list[6]
    @list2 << @list[7]
    @list2 << @list[8]
    @list2 << @list[9]
  end

  it 'works' do
    expect do
      expect(@list.uniq!).to be(nil)
    end.not_to raise_error
    @list[1] = @list[0]
    @list.scene = 7
    cur = @list.cur_image
    list = @list
    @list.uniq!
    expect(@list).to be(list)
    expect(@list.cur_image).to be(cur)
    expect(@list.scene).to eq(6)
    @list[5] = @list[6]
    @list.uniq!
    expect(@list.cur_image).to be(cur)
    expect(@list.scene).to eq(5)
  end
end

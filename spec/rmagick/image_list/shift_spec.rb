RSpec.describe Magick::ImageList, '#shift' do
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
    expect do
      @list.scene = 0
      res = @list[0]
      img = @list.shift
      expect(img).to be(res)
      expect(@list.scene).to eq(8)
    end.not_to raise_error
    res = @list[0]
    img = @list.shift
    expect(img).to be(res)
    expect(@list.scene).to eq(7)
  end
end

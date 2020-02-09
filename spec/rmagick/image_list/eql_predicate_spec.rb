RSpec.describe Magick::ImageList, '#eql?' do
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
    list2 = @list
    expect(@list.eql?(list2)).to be(true)
    list2 = @list.copy
    expect(@list.eql?(list2)).to be(false)
  end
end

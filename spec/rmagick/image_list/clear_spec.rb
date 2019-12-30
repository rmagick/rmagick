RSpec.describe Magick::ImageList, '#clear' do
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
    expect { @list.clear }.not_to raise_error
    expect(@list).to be_instance_of(Magick::ImageList)
    expect(@list.length).to eq(0)
    expect(@list.scene).to be(nil)
  end
end

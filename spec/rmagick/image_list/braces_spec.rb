RSpec.describe Magick::ImageList, '#[]' do
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
    expect { @list[0] }.not_to raise_error
    expect(@list[0]).to be_instance_of(Magick::Image)
    expect(@list[-1]).to be_instance_of(Magick::Image)
    expect(@list[0, 1]).to be_instance_of(Magick::ImageList)
    expect(@list[0..2]).to be_instance_of(Magick::ImageList)
    expect(@list[20]).to be(nil)
  end
end

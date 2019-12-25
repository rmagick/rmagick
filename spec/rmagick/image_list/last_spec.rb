RSpec.describe Magick::ImageList, '#last' do
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
    img = Magick::Image.new(5, 5)
    @list << img
    img2 = nil
    expect { img2 = @list.last }.not_to raise_error
    expect(img2).to be_instance_of(Magick::Image)
    expect(img).to eq(img2)
    img2 = Magick::Image.new(5, 5)
    @list << img2
    ilist = nil
    expect { ilist = @list.last(2) }.not_to raise_error
    expect(ilist).to be_instance_of(Magick::ImageList)
    expect(ilist.length).to eq(2)
    expect(ilist.scene).to eq(1)
    expect(ilist[0]).to eq(img)
    expect(ilist[1]).to eq(img2)
  end
end

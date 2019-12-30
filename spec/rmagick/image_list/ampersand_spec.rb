RSpec.describe Magick::ImageList, '#&' do
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
    @list.scene = 7
    cur = @list.cur_image
    expect do
      res = @list & @list2
      expect(res).to be_instance_of(Magick::ImageList)
      expect(@list).not_to be(res)
      expect(@list2).not_to be(res)
      expect(res.length).to eq(5)
      expect(res.scene).to eq(2)
      expect(res.cur_image).to be(cur)
    end.not_to raise_error

    # current scene not in the result, set result scene to last image in result
    @list.scene = 2
    expect do
      res = @list & @list2
      expect(res).to be_instance_of(Magick::ImageList)
      expect(res.scene).to eq(4)
    end.not_to raise_error

    expect { @list & 2 }.to raise_error(ArgumentError)
  end
end

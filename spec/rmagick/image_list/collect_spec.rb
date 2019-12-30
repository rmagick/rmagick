RSpec.describe Magick::ImageList, '#collect' do
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
      scene = @list.scene
      res = @list.collect(&:negate)
      expect(res).to be_instance_of(Magick::ImageList)
      expect(@list).not_to be(res)
      expect(res.scene).to eq(scene)
    end.not_to raise_error
    expect do
      scene = @list.scene
      @list.collect!(&:negate)
      expect(@list).to be_instance_of(Magick::ImageList)
      expect(@list.scene).to eq(scene)
    end.not_to raise_error
  end
end

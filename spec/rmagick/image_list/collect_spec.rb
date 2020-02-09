RSpec.describe Magick::ImageList, '#collect' do
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
      scene = @list.scene
      res = @list.collect(&:negate)
      expect(res).to be_instance_of(described_class)
      expect(@list).not_to be(res)
      expect(res.scene).to eq(scene)
    end.not_to raise_error
    expect do
      scene = @list.scene
      @list.collect!(&:negate)
      expect(@list).to be_instance_of(described_class)
      expect(@list.scene).to eq(scene)
    end.not_to raise_error
  end
end

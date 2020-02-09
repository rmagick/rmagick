RSpec.describe Magick::ImageList, '#compact' do
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
      res = @list.compact
      expect(@list).not_to be(res)
      expect(@list).to eq(res)
    end.not_to raise_error
    expect do
      res = @list
      @list.compact!
      expect(@list).to be_instance_of(described_class)
      expect(@list).to eq(res)
      expect(@list).to be(res)
    end.not_to raise_error
  end
end

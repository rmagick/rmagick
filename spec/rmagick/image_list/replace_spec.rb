RSpec.describe Magick::ImageList, '#replace' do
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
    # Replace with empty list
    expect do
      res = @list.replace([])
      expect(@list).to be(res)
      expect(@list.length).to eq(0)
      expect(@list.scene).to be(nil)
    end.not_to raise_error

    # Replace empty list with non-empty list
    temp = described_class.new
    expect do
      temp.replace(@list2)
      expect(temp.length).to eq(5)
      expect(temp.scene).to eq(4)
    end.not_to raise_error

    # Try to replace with illegal values
    expect { @list.replace([1, 2, 3]) }.to raise_error(ArgumentError)
  end

  it 'replaces with a shorter list' do
    expect do
      @list.scene = 7
      cur = @list.cur_image
      res = @list.replace(@list2)
      expect(@list).to be(res)
      expect(@list.length).to eq(5)
      expect(@list.scene).to eq(2)
      expect(@list.cur_image).to be(cur)
    end.not_to raise_error
  end

  it 'replaces with a longer list' do
    # Replace with longer list
    expect do
      @list2.scene = 2
      cur = @list2.cur_image
      res = @list2.replace(@list)
      expect(@list2).to be(res)
      expect(@list2.length).to eq(10)
      expect(@list2.scene).to eq(7)
      expect(@list2.cur_image).to be(cur)
    end.not_to raise_error
  end
end

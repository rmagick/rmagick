RSpec.describe Magick::ImageList, '#+' do
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
    @list.scene = 7
    cur = @list.cur_image
    expect do
      res = @list + @list2
      expect(res).to be_instance_of(described_class)
      expect(res.length).to eq(15)
      expect(@list).not_to be(res)
      expect(@list2).not_to be(res)
      expect(res.cur_image).to be(cur)
    end.not_to raise_error

    expect { @list + [2] }.to raise_error(ArgumentError)
  end
end

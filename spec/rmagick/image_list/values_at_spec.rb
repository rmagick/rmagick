RSpec.describe Magick::ImageList, '#values_at' do
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
    ilist = nil
    expect { ilist = @list.values_at(1, 3, 5) }.not_to raise_error
    expect(ilist).to be_instance_of(described_class)
    expect(ilist.length).to eq(3)
    expect(ilist.scene).to eq(2)
  end
end

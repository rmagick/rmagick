RSpec.describe Magick::ImageList, '#[]' do
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
    expect { @list[0] }.not_to raise_error
    expect(@list[0]).to be_instance_of(Magick::Image)
    expect(@list[-1]).to be_instance_of(Magick::Image)
    expect(@list[0, 1]).to be_instance_of(described_class)
    expect(@list[0..2]).to be_instance_of(described_class)
    expect(@list[20]).to be(nil)
  end
end

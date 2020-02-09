RSpec.describe Magick::ImageList, '#rindex' do
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
    img = @list.last
    n = nil
    expect { n = @list.rindex(img) }.not_to raise_error
    expect(n).to eq(9)
  end
end

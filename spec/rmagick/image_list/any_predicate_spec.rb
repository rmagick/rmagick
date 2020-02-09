RSpec.describe Magick::ImageList, '#any?' do
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
    q = nil
    expect { q = @list.any? { |_i| false } }.not_to raise_error
    expect(q).to be(false)
    expect { q = @list.any? { |i| i.class == Magick::Image } }.not_to raise_error
    expect(q).to be(true)
  end
end

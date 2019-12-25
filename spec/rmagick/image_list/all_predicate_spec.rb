RSpec.describe Magick::ImageList, '#all?' do
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
    q = nil
    expect { q = @list.all? { |i| i.class == Magick::Image } }.not_to raise_error
    expect(q).to be(true)
  end
end

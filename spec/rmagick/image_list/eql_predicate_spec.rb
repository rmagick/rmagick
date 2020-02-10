RSpec.describe Magick::ImageList, '#eql?' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    list2 = @list
    expect(@list.eql?(list2)).to be(true)
    list2 = @list.copy
    expect(@list.eql?(list2)).to be(false)
  end
end

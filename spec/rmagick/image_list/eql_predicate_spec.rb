RSpec.describe Magick::ImageList, '#eql?' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list2 = list
    expect(list.eql?(list2)).to be(true)
    list2 = list.copy
    expect(list.eql?(list2)).to be(false)
  end
end

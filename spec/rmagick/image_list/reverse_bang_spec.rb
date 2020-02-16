RSpec.describe Magick::ImageList, '#reverse!' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    cur = list.cur_image
    list2 = nil
    expect { list2 = list.reverse! }.not_to raise_error
    expect(list2).to be(list)
    expect(list.cur_image).to be(cur)
  end
end

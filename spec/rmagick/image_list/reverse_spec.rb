RSpec.describe Magick::ImageList, '#reverse' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list2 = nil
    cur = list.cur_image
    expect { list2 = list.reverse }.not_to raise_error
    expect(list.length).to eq(list2.length)
    expect(list.cur_image).to be(cur)
  end
end

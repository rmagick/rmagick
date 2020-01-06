RSpec.describe Magick::ImageList, '#uniq!' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect do
      expect(list.uniq!).to be(nil)
    end.not_to raise_error
    list[1] = list[0]
    list.scene = 7
    cur = list.cur_image
    list2 = list
    list.uniq!
    expect(list).to be(list2)
    expect(list.cur_image).to be(cur)
    expect(list.scene).to eq(6)
    list[5] = list[6]
    list.uniq!
    expect(list.cur_image).to be(cur)
    expect(list.scene).to eq(5)
  end
end

RSpec.describe Magick::ImageList, '#pop' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.scene = 8
    cur = list.cur_image
    last = list[-1]
    expect do
      expect(list.pop).to be(last)
      expect(list.cur_image).to be(cur)
    end.not_to raise_error

    expect(list.pop).to be(cur)
    expect(list.cur_image).to be(list[-1])
  end
end

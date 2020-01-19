RSpec.describe Magick::ImageList, '#at' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    expect do
      cur = @list.cur_image
      img = @list.at(7)
      expect(@list[7]).to be(img)
      expect(@list.cur_image).to be(cur)
      img = @list.at(10)
      expect(img).to be(nil)
      expect(@list.cur_image).to be(cur)
      img = @list.at(-1)
      expect(@list[9]).to be(img)
      expect(@list.cur_image).to be(cur)
    end.not_to raise_error
  end
end

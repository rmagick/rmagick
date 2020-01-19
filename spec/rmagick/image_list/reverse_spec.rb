RSpec.describe Magick::ImageList, '#reverse' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    list2 = nil
    cur = @list.cur_image
    expect { list2 = @list.reverse }.not_to raise_error
    expect(@list.length).to eq(list2.length)
    expect(@list.cur_image).to be(cur)
  end
end

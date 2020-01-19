RSpec.describe Magick::ImageList, '#reverse!' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    list2 = @list
    cur = @list.cur_image
    expect { @list.reverse! }.not_to raise_error
    expect(@list).to be(list2)
    expect(@list.cur_image).to be(cur)
  end
end

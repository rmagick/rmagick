RSpec.describe Magick::ImageList, '#delete_at' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    @list.scene = 7
    cur = @list.cur_image
    expect { @list.delete_at(9) }.not_to raise_error
    expect(@list.cur_image).to be(cur)
    expect { @list.delete_at(7) }.not_to raise_error
    expect(@list.cur_image).to be(@list[-1])
  end
end

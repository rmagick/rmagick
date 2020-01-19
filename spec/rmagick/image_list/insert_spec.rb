RSpec.describe Magick::ImageList, '#insert' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    expect do
      @list.scene = 7
      cur = @list.cur_image
      expect(@list.insert(1, @list[2])).to be_instance_of(described_class)
      expect(@list.cur_image).to be(cur)
      @list.insert(1, @list[2], @list[3], @list[4])
      expect(@list.cur_image).to be(cur)
    end.not_to raise_error

    expect { @list.insert(0, 'x') }.to raise_error(ArgumentError)
    expect { @list.insert(0, 'x', 'y') }.to raise_error(ArgumentError)
  end
end

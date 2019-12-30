RSpec.describe Magick::ImageList, '#delay' do
  before do
    @list = Magick::ImageList.new(*FILES[0..9])
    @list2 = Magick::ImageList.new # intersection is 5..9
    @list2 << @list[5]
    @list2 << @list[6]
    @list2 << @list[7]
    @list2 << @list[8]
    @list2 << @list[9]
  end

  it 'works' do
    expect { @list.delay }.not_to raise_error
    expect(@list.delay).to eq(0)
    expect { @list.delay = 20 }.not_to raise_error
    expect(@list.delay).to eq(20)
    expect { @list.delay = 'x' }.to raise_error(ArgumentError)
  end
end

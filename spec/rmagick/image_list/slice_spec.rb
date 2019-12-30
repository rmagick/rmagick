RSpec.describe Magick::ImageList, '#slice' do
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
    expect { @list.slice(0) }.not_to raise_error
    expect { @list.slice(-1) }.not_to raise_error
    expect { @list.slice(0, 1) }.not_to raise_error
    expect { @list.slice(0..2) }.not_to raise_error
    expect { @list.slice(20) }.not_to raise_error
  end
end

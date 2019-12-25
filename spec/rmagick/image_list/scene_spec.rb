RSpec.describe Magick::ImageList, '#scene' do
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
    expect { @list.scene }.not_to raise_error
    expect(@list.scene).to eq(9)
    expect { @list.scene = 0 }.not_to raise_error
    expect(@list.scene).to eq(0)
    expect { @list.scene = 1 }.not_to raise_error
    expect(@list.scene).to eq(1)
    expect { @list.scene = -1 }.to raise_error(IndexError)
    expect { @list.scene = 1000 }.to raise_error(IndexError)
    expect { @list.scene = nil }.to raise_error(IndexError)

    # allow nil on empty list
    empty_list = Magick::ImageList.new
    expect { empty_list.scene = nil }.not_to raise_error
  end
end

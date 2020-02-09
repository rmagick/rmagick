RSpec.describe Magick::ImageList, '#ticks_per_second' do
  before do
    @list = described_class.new(*FILES[0..9])
    @list2 = described_class.new # intersection is 5..9
    @list2 << @list[5]
    @list2 << @list[6]
    @list2 << @list[7]
    @list2 << @list[8]
    @list2 << @list[9]
  end

  it 'works' do
    expect { @list.ticks_per_second }.not_to raise_error
    expect(@list.ticks_per_second).to eq(100)
    expect { @list.ticks_per_second = 1000 }.not_to raise_error
    expect(@list.ticks_per_second).to eq(1000)
    expect { @list.ticks_per_second = 'x' }.to raise_error(ArgumentError)
  end
end

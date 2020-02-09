RSpec.describe Magick::ImageList, '#<=>' do
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
    list2 = @list.copy
    expect(list2.scene).to eq(@list.scene)
    expect(list2).to eq(@list)
    list2.scene = 0
    expect(list2).not_to eq(@list)
    list2 = @list.copy
    list2[9] = list2[0]
    expect(list2).not_to eq(@list)
    list2 = @list.copy
    list2 << @list[9]
    expect(list2).not_to eq(@list)

    expect { @list <=> 2 }.to raise_error(TypeError)
    list = described_class.new
    list2 = described_class.new
    expect { list2 <=> @list }.to raise_error(TypeError)
    expect { @list <=> list2 }.to raise_error(TypeError)
    expect { list <=> list2 }.not_to raise_error
  end
end

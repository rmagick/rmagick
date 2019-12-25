RSpec.describe Magick::ImageList, '#<=>' do
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
    list = Magick::ImageList.new
    list2 = Magick::ImageList.new
    expect { list2 <=> @list }.to raise_error(TypeError)
    expect { @list <=> list2 }.to raise_error(TypeError)
    expect { list <=> list2 }.not_to raise_error
  end
end

RSpec.describe Magick::ImageList, '#length' do
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
    expect { @list.length }.not_to raise_error
    expect(@list.length).to eq(10)
    expect { @list.length = 2 }.to raise_error(NoMethodError)
  end
end

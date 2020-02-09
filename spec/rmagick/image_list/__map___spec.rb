RSpec.describe Magick::ImageList, '#__map__' do
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
    img = @list[0]
    expect do
      @list.__map__ { |_x| img }
    end.not_to raise_error
    expect(@list).to be_instance_of(described_class)
    expect { @list.__map__ { 2 } }.to raise_error(ArgumentError)
  end
end

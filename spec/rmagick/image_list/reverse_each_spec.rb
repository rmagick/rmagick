RSpec.describe Magick::ImageList, '#reverse_each' do
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
    expect do
      @list.reverse_each { |img| expect(img).to be_instance_of(Magick::Image) }
    end.not_to raise_error
  end
end

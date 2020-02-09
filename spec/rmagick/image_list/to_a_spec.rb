RSpec.describe Magick::ImageList, '#to_a' do
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
    a = nil
    expect { a = @list.to_a }.not_to raise_error
    expect(a).to be_instance_of(Array)
    expect(a.length).to eq(10)
  end
end

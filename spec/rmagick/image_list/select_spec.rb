RSpec.describe Magick::ImageList, '#select' do
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
      res = @list.select { |img| File.basename(img.filename) =~ /Button_2/ }
      expect(res).to be_instance_of(described_class)
      expect(res.length).to eq(1)
      expect(@list[2]).to be(res[0])
    end.not_to raise_error
  end
end

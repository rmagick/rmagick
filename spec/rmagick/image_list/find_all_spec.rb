RSpec.describe Magick::ImageList, '#find_all' do
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
    expect do
      res = @list.find_all { |img| File.basename(img.filename) =~ /Button_2/ }
      expect(res).to be_instance_of(Magick::ImageList)
      expect(res.length).to eq(1)
      expect(@list[2]).to be(res[0])
    end.not_to raise_error
  end
end

RSpec.describe Magick::ImageList, '#reject' do
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
    @list.scene = 7
    cur = @list.cur_image
    list2 = @list
    expect do
      res = @list.reject { |img| File.basename(img.filename) =~ /Button_9/ }
      expect(res.length).to eq(9)
      expect(res).to be_instance_of(described_class)
      expect(res.cur_image).to be(cur)
    end.not_to raise_error
    expect(@list).to be(list2)
    expect(@list.cur_image).to be(cur)

    # Omit current image from result list - result cur_image s/b last image
    res = @list.reject { |img| File.basename(img.filename) =~ /Button_7/ }
    expect(res.length).to eq(9)
    expect(res.cur_image).to be(res[-1])
    expect(@list.cur_image).to be(cur)
  end
end

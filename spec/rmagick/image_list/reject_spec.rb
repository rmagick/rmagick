RSpec.describe Magick::ImageList, '#reject' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.scene = 7
    cur = list.cur_image
    list2 = list

    res = list.reject { |img| File.basename(img.filename) =~ /Button_9/ }
    expect(res.length).to eq(9)
    expect(res).to be_instance_of(described_class)
    expect(res.cur_image).to be(cur)

    expect(list).to be(list2)
    expect(list.cur_image).to be(cur)

    # Omit current image from result list - result cur_image s/b last image
    res = list.reject { |img| File.basename(img.filename) =~ /Button_7/ }
    expect(res.length).to eq(9)
    expect(res.cur_image).to be(res[-1])
    expect(list.cur_image).to be(cur)
  end
end

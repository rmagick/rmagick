RSpec.describe Magick::ImageList, '#reject' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.scene = 7
    cur = list.cur_image
    list2 = list

    result = list.reject { |image| File.basename(image.filename) =~ /Button_9/ }
    expect(result.length).to eq(9)
    expect(result).to be_instance_of(described_class)
    expect(result.cur_image).to be(cur)

    expect(list).to be(list2)
    expect(list.cur_image).to be(cur)

    # Omit current image from result list - result cur_image s/b last image
    result = list.reject { |image| File.basename(image.filename) =~ /Button_7/ }
    expect(result.length).to eq(9)
    expect(result.cur_image).to be(result[-1])
    expect(list.cur_image).to be(cur)
  end
end

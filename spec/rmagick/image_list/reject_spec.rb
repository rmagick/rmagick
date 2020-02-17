RSpec.describe Magick::ImageList, '#reject' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.scene = 7
    cur = image_list.cur_image
    image_list2 = image_list

    result = image_list.reject { |image| File.basename(image.filename) =~ /Button_9/ }
    expect(result.length).to eq(9)
    expect(result).to be_instance_of(described_class)
    expect(result.cur_image).to be(cur)

    expect(image_list).to be(image_list2)
    expect(image_list.cur_image).to be(cur)

    # Omit current image from result image_list - result cur_image s/b last image
    result = image_list.reject { |image| File.basename(image.filename) =~ /Button_7/ }
    expect(result.length).to eq(9)
    expect(result.cur_image).to be(result[-1])
    expect(image_list.cur_image).to be(cur)
  end
end

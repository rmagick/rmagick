RSpec.describe Magick::ImageList, '#reject!' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.scene = 7
    cur = image_list.cur_image

    image_list.reject! { |image| File.basename(image.filename) =~ /5/ }
    expect(image_list).to be_instance_of(described_class)
    expect(image_list.length).to eq(9)
    expect(image_list.cur_image).to be(cur)

    # Delete the current image
    image_list.reject! { |image| File.basename(image.filename) =~ /7/ }
    expect(image_list).to be_instance_of(described_class)
    expect(image_list.length).to eq(8)
    expect(image_list.cur_image).to be(image_list[-1])

    # returns nil if no changes are made
    expect(image_list.reject! { false }).to be(nil)
  end
end

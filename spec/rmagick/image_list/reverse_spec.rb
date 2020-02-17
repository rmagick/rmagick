RSpec.describe Magick::ImageList, '#reverse' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list2 = nil
    cur = image_list.cur_image
    expect { image_list2 = image_list.reverse }.not_to raise_error
    expect(image_list.length).to eq(image_list2.length)
    expect(image_list.cur_image).to be(cur)
  end
end

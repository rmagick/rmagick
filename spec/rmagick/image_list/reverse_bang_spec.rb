RSpec.describe Magick::ImageList, '#reverse!' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    cur = image_list.cur_image
    image_list2 = nil
    expect { image_list2 = image_list.reverse! }.not_to raise_error
    expect(image_list2).to be(image_list)
    expect(image_list.cur_image).to be(cur)
  end
end

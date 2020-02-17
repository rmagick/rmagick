RSpec.describe Magick::ImageList, '#delete_at' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.scene = 7
    cur = image_list.cur_image
    expect { image_list.delete_at(9) }.not_to raise_error
    expect(image_list.cur_image).to be(cur)
    expect { image_list.delete_at(7) }.not_to raise_error
    expect(image_list.cur_image).to be(image_list[-1])
  end
end

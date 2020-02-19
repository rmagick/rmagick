RSpec.describe Magick::ImageList, '#delete' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    cur = image_list.cur_image
    image = image_list[7]
    expect(image_list.delete(image)).to be(image)
    expect(image_list.length).to eq(9)
    expect(image_list.cur_image).to be(cur)

    # Try deleting the current image.
    expect(image_list.delete(cur)).to be(cur)
    expect(image_list.cur_image).to be(image_list[-1])

    expect { image_list.delete(2) }.to raise_error(ArgumentError)
    expect { image_list.delete([2]) }.to raise_error(ArgumentError)

    # Try deleting something that isn't in the image_list.
    # Should return the value of the block.
    image = Magick::Image.read(FILES[10]).first
    result = image_list.delete(image) { 1 }
    expect(result).to eq(1)
  end
end

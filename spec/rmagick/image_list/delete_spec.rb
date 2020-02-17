RSpec.describe Magick::ImageList, '#delete' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    cur = list.cur_image
    img = list[7]
    expect(list.delete(img)).to be(img)
    expect(list.length).to eq(9)
    expect(list.cur_image).to be(cur)

    # Try deleting the current image.
    expect(list.delete(cur)).to be(cur)
    expect(list.cur_image).to be(list[-1])

    expect { list.delete(2) }.to raise_error(ArgumentError)
    expect { list.delete([2]) }.to raise_error(ArgumentError)

    # Try deleting something that isn't in the list.
    # Should return the value of the block.
    img = Magick::Image.read(FILES[10]).first
    res = list.delete(img) { 1 }
    expect(res).to eq(1)
  end
end

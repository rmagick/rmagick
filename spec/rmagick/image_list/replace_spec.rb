RSpec.describe Magick::ImageList, '#replace' do
  def make_lists
    image_list = Magick::ImageList.new(*FILES[0..9])
    image_list2 = Magick::ImageList.new # intersection is 5..9
    image_list2 << image_list[5]
    image_list2 << image_list[6]
    image_list2 << image_list[7]
    image_list2 << image_list[8]
    image_list2 << image_list[9]
    [image_list, image_list2]
  end

  it 'works' do
    image_list, image_list2 = make_lists

    # Replace with empty image_list
    result = image_list.replace([])
    expect(image_list).to be(result)
    expect(image_list.length).to eq(0)
    expect(image_list.scene).to be(nil)

    # Replace empty image_list with non-empty image_list
    temp = described_class.new

    temp.replace(image_list2)
    expect(temp.length).to eq(5)
    expect(temp.scene).to eq(4)

    # Try to replace with illegal values
    expect { image_list.replace([1, 2, 3]) }.to raise_error(ArgumentError)
  end

  it 'replaces with a shorter image_list' do
    image_list, image_list2 = make_lists

    image_list.scene = 7
    cur = image_list.cur_image
    result = image_list.replace(image_list2)
    expect(image_list).to be(result)
    expect(image_list.length).to eq(5)
    expect(image_list.scene).to eq(2)
    expect(image_list.cur_image).to be(cur)
  end

  it 'replaces with a longer image_list' do
    image_list, image_list2 = make_lists

    # Replace with longer image_list
    image_list2.scene = 2
    cur = image_list2.cur_image
    result = image_list2.replace(image_list)
    expect(image_list2).to be(result)
    expect(image_list2.length).to eq(10)
    expect(image_list2.scene).to eq(7)
    expect(image_list2.cur_image).to be(cur)
  end
end

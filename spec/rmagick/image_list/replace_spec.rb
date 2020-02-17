RSpec.describe Magick::ImageList, '#replace' do
  def make_lists
    list = Magick::ImageList.new(*FILES[0..9])
    list2 = Magick::ImageList.new # intersection is 5..9
    list2 << list[5]
    list2 << list[6]
    list2 << list[7]
    list2 << list[8]
    list2 << list[9]
    [list, list2]
  end

  it 'works' do
    list, list2 = make_lists

    # Replace with empty list
    result = list.replace([])
    expect(list).to be(result)
    expect(list.length).to eq(0)
    expect(list.scene).to be(nil)

    # Replace empty list with non-empty list
    temp = described_class.new

    temp.replace(list2)
    expect(temp.length).to eq(5)
    expect(temp.scene).to eq(4)

    # Try to replace with illegal values
    expect { list.replace([1, 2, 3]) }.to raise_error(ArgumentError)
  end

  it 'replaces with a shorter list' do
    list, list2 = make_lists

    list.scene = 7
    cur = list.cur_image
    result = list.replace(list2)
    expect(list).to be(result)
    expect(list.length).to eq(5)
    expect(list.scene).to eq(2)
    expect(list.cur_image).to be(cur)
  end

  it 'replaces with a longer list' do
    list, list2 = make_lists

    # Replace with longer list
    list2.scene = 2
    cur = list2.cur_image
    result = list2.replace(list)
    expect(list2).to be(result)
    expect(list2.length).to eq(10)
    expect(list2.scene).to eq(7)
    expect(list2.cur_image).to be(cur)
  end
end

RSpec.describe Magick::ImageList, '#-' do
  it 'works' do
    list = described_class.new(*FILES[0..9])
    list2 = described_class.new # intersection is 5..9
    list2 << list[5]
    list2 << list[6]
    list2 << list[7]
    list2 << list[8]
    list2 << list[9]

    list.scene = 0
    cur = list.cur_image

    res = list - list2
    expect(res).to be_instance_of(described_class)
    expect(res.length).to eq(5)
    expect(list).not_to be(res)
    expect(list2).not_to be(res)
    expect(res.cur_image).to be(cur)

    # current scene not in result - set result scene to last image in result
    list.scene = 7

    res = list - list2
    expect(res).to be_instance_of(described_class)
    expect(res.length).to eq(5)
    expect(res.scene).to eq(4)
  end
end

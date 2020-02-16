RSpec.describe Magick::ImageList, '#concat' do
  it 'allows appending identical instances more than once' do
    img = Magick::Image.new(1, 1)
    img2 = Magick::Image.new(3, 3)
    list = described_class.new

    list.concat([img, img2, img, img2, img])

    res = list.append(false)
    expect(res.columns).to eq(9)
    expect(res.rows).to eq(3)
  end

  it 'works' do
    list = described_class.new(*FILES[0..9])
    list2 = described_class.new # intersection is 5..9
    list2 << list[5]
    list2 << list[6]
    list2 << list[7]
    list2 << list[8]
    list2 << list[9]

    expect do
      res = list.concat(list2)
      expect(res).to be_instance_of(described_class)
      expect(res.length).to eq(15)
      expect(res.cur_image).to be(res[14])
    end.not_to raise_error
    expect { list.concat(2) }.to raise_error(ArgumentError)
    expect { list.concat([2]) }.to raise_error(ArgumentError)
  end
end

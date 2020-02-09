RSpec.describe Magick::ImageList, '#<<' do
  it 'allows appending identical instances more than once' do
    img = Magick::Image.new(1, 1)
    list = described_class.new

    list << img << img

    res = list.append(false)
    expect(res.columns).to eq(2)
    expect(res.rows).to eq(1)
  end

  it "works" do
    ilist = described_class.new
    ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')
    expect do
      img = ilist.append(true)
      expect(img).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect do
      img = ilist.append(false)
      expect(img).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { ilist.append }.to raise_error(ArgumentError)
    expect { ilist.append(true, 1) }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::ImageList, '#<<' do
  it 'allows appending identical instances more than once' do
    image = Magick::Image.new(1, 1)
    list = described_class.new

    list << image << image

    result = list.append(false)
    expect(result.columns).to eq(2)
    expect(result.rows).to eq(1)
  end

  it "works" do
    ilist = described_class.new
    ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')

    image = ilist.append(true)
    expect(image).to be_instance_of(Magick::Image)

    image = ilist.append(false)
    expect(image).to be_instance_of(Magick::Image)

    expect { ilist.append }.to raise_error(ArgumentError)
    expect { ilist.append(true, 1) }.to raise_error(ArgumentError)
  end
end

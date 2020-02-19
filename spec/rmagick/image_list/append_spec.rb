RSpec.describe Magick::ImageList, '#<<' do
  it 'allows appending identical instances more than once' do
    image = Magick::Image.new(1, 1)
    image_list = described_class.new

    image_list << image << image

    result = image_list.append(false)
    expect(result.columns).to eq(2)
    expect(result.rows).to eq(1)
  end

  it "works" do
    image_list = described_class.new
    image_list.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')

    image = image_list.append(true)
    expect(image).to be_instance_of(Magick::Image)

    image = image_list.append(false)
    expect(image).to be_instance_of(Magick::Image)

    expect { image_list.append }.to raise_error(ArgumentError)
    expect { image_list.append(true, 1) }.to raise_error(ArgumentError)
  end
end

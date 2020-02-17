RSpec.describe Magick::Image, '#blue_shift' do
  it 'returns a new Image' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    res = image.blue_shift
    expect(res).to be_instance_of(described_class)
    expect(res).not_to eq image
  end

  it 'accepts one argument' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    expect { image.blue_shift(2) }.not_to raise_error
    expect { image.blue_shift(2, 3) }.to raise_error(ArgumentError)
  end

  it "works" do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    expect(image.blue_shift).not_to be(image)
    expect(image.blue_shift(2.0)).not_to be(image)
    expect { image.blue_shift('x') }.to raise_error(TypeError)
    expect { image.blue_shift(2, 2) }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Image, '#blue_shift' do
  it 'returns a new Image' do
    img = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    res = img.blue_shift
    expect(res).to be_instance_of(described_class)
    expect(res).not_to eq img
  end

  it 'accepts one argument' do
    img = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    expect { img.blue_shift(2) }.not_to raise_error
    expect { img.blue_shift(2, 3) }.to raise_error(ArgumentError)
  end

  it "works" do
    img = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    expect(img.blue_shift).not_to be(img)
    expect(img.blue_shift(2.0)).not_to be(img)
    expect { img.blue_shift('x') }.to raise_error(TypeError)
    expect { img.blue_shift(2, 2) }.to raise_error(ArgumentError)
  end
end

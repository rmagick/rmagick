RSpec.describe Magick::Image, '#trim!' do
  it 'works' do
    hat = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    result = hat.trim!
    expect(result).to be(hat)

    result = hat.trim!(10)
    expect(result).to be(hat)

    expect { hat.trim!(10, 10) }.to raise_error(ArgumentError)
  end
end

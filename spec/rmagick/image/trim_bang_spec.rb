RSpec.describe Magick::Image, '#trim!' do
  it 'works' do
    hat = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    res = hat.trim!
    expect(res).to be(hat)

    res = hat.trim!(10)
    expect(res).to be(hat)

    expect { hat.trim!(10, 10) }.to raise_error(ArgumentError)
  end
end

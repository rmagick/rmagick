RSpec.describe Magick::Image, '#palette?' do
  it 'works' do
    image = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first

    expect(image.palette?).to be(false)

    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    expect(image.palette?).to be(true)
  end
end

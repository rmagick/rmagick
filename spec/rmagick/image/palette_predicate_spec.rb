RSpec.describe Magick::Image, '#palette?' do
  it 'works' do
    img = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    expect do
      expect(img.palette?).to be(false)
    end.not_to raise_error
    img = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect(img.palette?).to be(true)
  end
end

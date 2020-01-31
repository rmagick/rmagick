RSpec.describe Magick::Image, '#palette?' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    img = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    expect do
      expect(img.palette?).to be(false)
    end.not_to raise_error
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    expect(img.palette?).to be(true)
  end
end

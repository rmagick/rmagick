RSpec.describe Magick::Image, '#monochrome?' do
  it 'works' do
    image = described_class.new(20, 20)

    #       expect(image.monochrome?).to be(true)
    image.pixel_color(0, 0, 'red')
    expect(image.monochrome?).to be(false)
  end
end

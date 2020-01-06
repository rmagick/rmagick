RSpec.describe Magick::Image, '#monochrome?' do
  it 'works' do
    img = described_class.new(20, 20)

    #       expect(img.monochrome?).to be(true)
    img.pixel_color(0, 0, 'red')
    expect(img.monochrome?).to be(false)
  end
end

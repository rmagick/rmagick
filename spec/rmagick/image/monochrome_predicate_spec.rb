RSpec.describe Magick::Image, '#monochrome?' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    #       expect(@img.monochrome?).to be(true)
    @img.pixel_color(0, 0, 'red')
    expect(@img.monochrome?).to be(false)
  end
end

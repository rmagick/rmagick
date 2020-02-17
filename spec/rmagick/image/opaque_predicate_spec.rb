RSpec.describe Magick::Image, '#opaque?' do
  it 'works' do
    image = described_class.new(20, 20)

    expect(image.opaque?).to be(true)

    image.alpha(Magick::TransparentAlphaChannel)

    expect(image.opaque?).to be(false)
  end
end

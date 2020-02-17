RSpec.describe Magick::Image, '#opaque?' do
  it 'works' do
    img = described_class.new(20, 20)

    expect(img.opaque?).to be(true)

    img.alpha(Magick::TransparentAlphaChannel)

    expect(img.opaque?).to be(false)
  end
end

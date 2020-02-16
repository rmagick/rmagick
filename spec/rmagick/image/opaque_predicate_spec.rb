RSpec.describe Magick::Image, '#opaque?' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      expect(img.opaque?).to be(true)
    end.not_to raise_error
    img.alpha(Magick::TransparentAlphaChannel)
    expect(img.opaque?).to be(false)
  end
end

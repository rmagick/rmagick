RSpec.describe Magick::Image, '#opaque?' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      expect(@img.opaque?).to be(true)
    end.not_to raise_error
    @img.alpha(Magick::TransparentAlphaChannel)
    expect(@img.opaque?).to be(false)
  end
end

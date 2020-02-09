RSpec.describe Magick::Image, '#stegano' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    @img = described_class.new(100, 100) { self.background_color = 'black' }
    watermark = described_class.new(10, 10) { self.background_color = 'white' }
    expect do
      res = @img.stegano(watermark, 0)
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error

    watermark.destroy!
    expect { @img.stegano(watermark, 0) }.to raise_error(Magick::DestroyedImageError)
  end
end

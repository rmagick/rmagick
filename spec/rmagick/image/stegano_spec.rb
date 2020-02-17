RSpec.describe Magick::Image, '#stegano' do
  it 'works' do
    image = described_class.new(100, 100) { self.background_color = 'black' }
    watermark = described_class.new(10, 10) { self.background_color = 'white' }

    res = image.stegano(watermark, 0)
    expect(res).to be_instance_of(described_class)

    watermark.destroy!
    expect { image.stegano(watermark, 0) }.to raise_error(Magick::DestroyedImageError)
  end
end

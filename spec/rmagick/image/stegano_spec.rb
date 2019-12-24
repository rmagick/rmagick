RSpec.describe Magick::Image, '#stegano' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    @img = Magick::Image.new(100, 100) { self.background_color = 'black' }
    watermark = Magick::Image.new(10, 10) { self.background_color = 'white' }
    expect do
      res = @img.stegano(watermark, 0)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error

    watermark.destroy!
    expect { @img.stegano(watermark, 0) }.to raise_error(Magick::DestroyedImageError)
  end
end

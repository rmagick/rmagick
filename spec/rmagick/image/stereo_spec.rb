RSpec.describe Magick::Image, '#stereo' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.stereo(@img)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error

    img = Magick::Image.new(20, 20)
    img.destroy!
    expect { @img.stereo(img) }.to raise_error(Magick::DestroyedImageError)
  end
end

RSpec.describe Magick::Image, '#transverse' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.transverse
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect do
      res = @img.transverse!
      expect(res).to be_instance_of(Magick::Image)
      expect(res).to be(@img)
    end.not_to raise_error
  end
end

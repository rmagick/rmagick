RSpec.describe Magick::Image, '#strip!' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.strip!
      expect(res).to be(@img)
    end.not_to raise_error
  end
end

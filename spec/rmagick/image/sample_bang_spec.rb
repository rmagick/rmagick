RSpec.describe Magick::Image, '#sample!' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.sample!(2)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.sample!(0.50) }.to raise_error(FreezeError)
  end
end

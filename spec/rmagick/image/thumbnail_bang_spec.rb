RSpec.describe Magick::Image, '#thumbnail!' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.thumbnail!(2)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.thumbnail!(0.50) }.to raise_error(FreezeError)
  end
end

RSpec.describe Magick::Image, '#resample!' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.resample!(50)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.resample!(50) }.to raise_error(FreezeError)
  end
end

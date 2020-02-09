RSpec.describe Magick::Image, '#scale!' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.scale!(2)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.scale!(0.50) }.to raise_error(FreezeError)
  end
end

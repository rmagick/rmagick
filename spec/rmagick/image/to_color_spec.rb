RSpec.describe Magick::Image, '#to_color' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect do
      res = @img.to_color(red)
      expect(res).to eq('red')
    end.not_to raise_error
  end
end

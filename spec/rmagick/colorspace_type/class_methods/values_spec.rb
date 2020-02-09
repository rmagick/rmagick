RSpec.describe Magick::ColorspaceType, '.values' do
  it 'does not cause an infinite loop' do
    img = Magick::Image.new(1, 1)
    described_class.values do |value|
      next if value == Magick::SRGBColorspace

      expect(img.colorspace).not_to eq(value)
    end
  end
end

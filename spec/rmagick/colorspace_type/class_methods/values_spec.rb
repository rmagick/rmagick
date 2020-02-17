RSpec.describe Magick::ColorspaceType, '.values' do
  it 'does not cause an infinite loop' do
    image = Magick::Image.new(1, 1)
    described_class.values do |value|
      next if value == Magick::SRGBColorspace

      expect(image.colorspace).not_to eq(value)
    end
  end
end

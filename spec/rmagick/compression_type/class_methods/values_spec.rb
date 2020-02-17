RSpec.describe Magick::CompressionType, '.values' do
  it 'does not cause an infinite loop' do
    image = Magick::Image.new(1, 1)
    described_class.values do |value|
      image.compression = value
      expect(image.compression).to eq(value)
    end
  end
end

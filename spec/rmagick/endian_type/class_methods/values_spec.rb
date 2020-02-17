RSpec.describe Magick::EndianType, '.values' do
  it 'does not cause an infinite loop' do
    image = Magick::Image.new(1, 1)
    described_class.values do |value|
      image.endian = value
      expect(image.endian).to eq(value)
    end
  end
end

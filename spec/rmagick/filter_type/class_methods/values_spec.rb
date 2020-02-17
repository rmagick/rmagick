RSpec.describe Magick::FilterType, '.values' do
  it 'does not cause an infinite loop' do
    image = Magick::Image.new(1, 1)
    described_class.values do |value|
      image.filter = value
      expect(image.filter).to eq(value)
    end
  end
end

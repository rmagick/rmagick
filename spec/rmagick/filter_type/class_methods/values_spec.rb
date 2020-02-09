RSpec.describe Magick::FilterType, '.values' do
  it 'does not cause an infinite loop' do
    img = Magick::Image.new(1, 1)
    described_class.values do |value|
      img.filter = value
      expect(img.filter).to eq(value)
    end
  end
end

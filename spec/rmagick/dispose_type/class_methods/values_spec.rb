RSpec.describe Magick::DisposeType, '.values' do
  it 'does not cause an infinite loop' do
    image = Magick::Image.new(1, 1)
    described_class.values do |value|
      image.dispose = value
      expect(image.dispose).to eq(value)
    end
  end
end

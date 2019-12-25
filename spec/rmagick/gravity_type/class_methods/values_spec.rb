RSpec.describe Magick::GravityType, '.values' do
  it 'does not cause an infinite loop' do
    img = Magick::Image.new(1, 1)
    Magick::GravityType.values do |value|
      img.gravity = value
      expect(img.gravity).to eq(value)
    end
  end
end

RSpec.describe Magick::RenderingIntent, '.values' do
  it 'does not cause an infinite loop' do
    image = Magick::Image.new(1, 1)
    described_class.values do |value|
      image.rendering_intent = value
      expect(image.rendering_intent).to eq(value)
    end
  end
end

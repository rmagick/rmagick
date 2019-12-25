RSpec.describe Magick::RenderingIntent, '.values' do
  it 'does not cause an infinite loop' do
    img = Magick::Image.new(1, 1)
    Magick::RenderingIntent.values do |value|
      img.rendering_intent = value
      expect(img.rendering_intent).to eq(value)
    end
  end
end

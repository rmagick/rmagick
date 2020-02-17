RSpec.describe Magick::VirtualPixelMethod, '.values' do
  it 'does not cause an infinite loop' do
    image = Magick::Image.new(1, 1)
    described_class.values do |value|
      image.virtual_pixel_method = value
      expect(image.virtual_pixel_method).to eq(value)
    end
  end
end

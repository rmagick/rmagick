RSpec.describe Magick::VirtualPixelMethod, '.values' do
  it 'does not cause an infinite loop' do
    img = Magick::Image.new(1, 1)
    Magick::VirtualPixelMethod.values do |value|
      img.virtual_pixel_method = value
      expect(img.virtual_pixel_method).to eq(value)
    end
  end
end

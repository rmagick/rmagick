RSpec.describe Magick::PixelInterpolateMethod, '.values' do
  it 'does not cause an infinite loop' do
    img = Magick::Image.new(1, 1)
    Magick::PixelInterpolateMethod.values do |value|
      img.pixel_interpolation_method = value
      expect(img.pixel_interpolation_method).to eq(value)
    end
  end
end

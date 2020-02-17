RSpec.describe Magick::Image, '#pixel_interpolation_method' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.pixel_interpolation_method }.not_to raise_error
    expect(image.pixel_interpolation_method).to be_instance_of(Magick::PixelInterpolateMethod)
    expect(image.pixel_interpolation_method).to eq(Magick::UndefinedInterpolatePixel)
    expect { image.pixel_interpolation_method = Magick::AverageInterpolatePixel }.not_to raise_error
    expect(image.pixel_interpolation_method).to eq(Magick::AverageInterpolatePixel)

    Magick::PixelInterpolateMethod.values do |interpolate_pixel_method|
      expect { image.pixel_interpolation_method = interpolate_pixel_method }.not_to raise_error
    end
    expect { image.pixel_interpolation_method = 2 }.to raise_error(TypeError)
  end
end

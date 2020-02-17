RSpec.describe Magick::Image, '#virtual_pixel_method' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.virtual_pixel_method }.not_to raise_error
    expect(image.virtual_pixel_method).to eq(Magick::UndefinedVirtualPixelMethod)
    expect { image.virtual_pixel_method = Magick::EdgeVirtualPixelMethod }.not_to raise_error
    expect(image.virtual_pixel_method).to eq(Magick::EdgeVirtualPixelMethod)

    Magick::VirtualPixelMethod.values do |virtual_pixel_method|
      expect { image.virtual_pixel_method = virtual_pixel_method }.not_to raise_error
    end
    expect { image.virtual_pixel_method = 2 }.to raise_error(TypeError)
  end
end

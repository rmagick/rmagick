RSpec.describe Magick::Image, '#virtual_pixel_method' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.virtual_pixel_method }.not_to raise_error
    expect(@img.virtual_pixel_method).to eq(Magick::UndefinedVirtualPixelMethod)
    expect { @img.virtual_pixel_method = Magick::EdgeVirtualPixelMethod }.not_to raise_error
    expect(@img.virtual_pixel_method).to eq(Magick::EdgeVirtualPixelMethod)

    Magick::VirtualPixelMethod.values do |virtual_pixel_method|
      expect { @img.virtual_pixel_method = virtual_pixel_method }.not_to raise_error
    end
    expect { @img.virtual_pixel_method = 2 }.to raise_error(TypeError)
  end
end

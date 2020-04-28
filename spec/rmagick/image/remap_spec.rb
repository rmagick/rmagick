RSpec.describe Magick::Image, '#remap' do
  it 'works' do
    image = described_class.new(20, 20)
    remap_image = described_class.new(20, 20) { self.background_color = 'green' }

    expect { image.remap(remap_image) }.not_to raise_error
    expect { image.remap(remap_image, Magick::NoDitherMethod) }.not_to raise_error
    expect { image.remap(remap_image, Magick::RiemersmaDitherMethod) }.not_to raise_error
    expect { image.remap(remap_image, Magick::FloydSteinbergDitherMethod) }.not_to raise_error

    expect { image.remap }.to raise_error(ArgumentError)
    expect { image.remap(remap_image, Magick::NoDitherMethod, 1) }.to raise_error(ArgumentError)
    expect { image.remap(remap_image, 1) }.to raise_error(TypeError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.remap(image_list) }.not_to raise_error
    expect { image.remap(image_list, Magick::NoDitherMethod) }.not_to raise_error
  end
end

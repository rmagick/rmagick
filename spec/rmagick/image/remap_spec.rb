RSpec.describe Magick::Image, '#remap' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    remap_image = Magick::Image.new(20, 20) { self.background_color = 'green' }
    expect { @img.remap(remap_image) }.not_to raise_error
    expect { @img.remap(remap_image, Magick::NoDitherMethod) }.not_to raise_error
    expect { @img.remap(remap_image, Magick::RiemersmaDitherMethod) }.not_to raise_error
    expect { @img.remap(remap_image, Magick::FloydSteinbergDitherMethod) }.not_to raise_error

    expect { @img.remap }.to raise_error(ArgumentError)
    expect { @img.remap(remap_image, Magick::NoDitherMethod, 1) }.to raise_error(ArgumentError)
    expect { @img.remap(remap_image, 1) }.to raise_error(TypeError)
  end
end

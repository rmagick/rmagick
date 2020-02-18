RSpec.describe Magick::ImageList, "#remap" do
  it "works" do
    image_list = described_class.new

    image_list.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    expect { image_list.remap }.not_to raise_error
    remap_image = Magick::Image.new(20, 20) { self.background_color = 'green' }
    expect { image_list.remap(remap_image) }.not_to raise_error
    expect { image_list.remap(remap_image, Magick::NoDitherMethod) }.not_to raise_error
    expect { image_list.remap(remap_image, Magick::RiemersmaDitherMethod) }.not_to raise_error
    expect { image_list.remap(remap_image, Magick::FloydSteinbergDitherMethod) }.not_to raise_error
    expect { image_list.remap(remap_image, Magick::NoDitherMethod, 1) }.to raise_error(ArgumentError)

    remap_image.destroy!
    expect { image_list.remap(remap_image) }.to raise_error(Magick::DestroyedImageError)
    # expect { image_list.affinity(affinity_image, 1) }.to raise_error(TypeError)
  end
end

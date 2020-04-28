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

  it 'accepts an ImageList argument' do
    image_list = described_class.new

    image_list.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    remap_image_list = described_class.new
    remap_image_list.new_image(10, 10)
    expect { image_list.remap(remap_image_list) }.not_to raise_error
    expect { image_list.remap(remap_image_list, Magick::NoDitherMethod) }.not_to raise_error
  end
end

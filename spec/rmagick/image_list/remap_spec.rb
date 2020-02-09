RSpec.describe Magick::ImageList, "#remap" do
  before do
    @ilist = described_class.new
  end

  it "works" do
    @ilist.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    expect { @ilist.remap }.not_to raise_error
    remap_image = Magick::Image.new(20, 20) { self.background_color = 'green' }
    expect { @ilist.remap(remap_image) }.not_to raise_error
    expect { @ilist.remap(remap_image, Magick::NoDitherMethod) }.not_to raise_error
    expect { @ilist.remap(remap_image, Magick::RiemersmaDitherMethod) }.not_to raise_error
    expect { @ilist.remap(remap_image, Magick::FloydSteinbergDitherMethod) }.not_to raise_error
    expect { @ilist.remap(remap_image, Magick::NoDitherMethod, 1) }.to raise_error(ArgumentError)

    remap_image.destroy!
    expect { @ilist.remap(remap_image) }.to raise_error(Magick::DestroyedImageError)
    # expect { @ilist.affinity(affinity_image, 1) }.to raise_error(TypeError)
  end
end

# frozen_string_literal: true

RSpec.describe Magick::ImageList, "#remap" do
  it "works" do
    image_list = described_class.new

    image_list.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    expect { image_list.remap }.not_to raise_error
    remap_image = Magick::Image.new(20, 20) { |options| options.background_color = 'green' }
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

  it 'does not let an image be frozen while it copies a repeated image' do
    image = Magick::Image.new(2, 2)
    other = Magick::Image.new(2, 2)
    image_list = described_class.new
    image_list << image << other << other
    palette = Magick::Image.new(2, 2)
    error = nil
    freeze = lambda do
      image.freeze
    rescue RuntimeError => e
      error = e.message
    end

    during_call(freeze) { image_list.remap(palette) }

    expect(error).to eq('object is in use by another fiber')
    expect(image).not_to be_frozen
  end

  it 'does not let the remap image be destroyed while it copies a repeated image' do
    image = Magick::Image.new(2, 2)
    image_list = described_class.new
    image_list << image << image
    palette = Magick::Image.new(2, 2)
    error = nil
    destroy = lambda do
      palette.destroy!
    rescue RuntimeError => e
      error = e.message
    end

    during_call(destroy) { image_list.remap(palette) }

    expect(error).to eq('object is in use by another fiber')
    expect(palette).not_to be_destroyed
  end

  it 'does not let a later image be frozen while it copies a repeated image' do
    image = Magick::Image.new(2, 2)
    later = Magick::Image.new(2, 2)
    image_list = described_class.new
    image_list << image << image << later
    palette = Magick::Image.new(2, 2)
    error = nil
    freeze = lambda do
      later.freeze
    rescue RuntimeError => e
      error = e.message
    end

    during_call(freeze) { image_list.remap(palette) }

    expect(error).to eq('object is in use by another fiber')
    expect(later).not_to be_frozen
  end
end

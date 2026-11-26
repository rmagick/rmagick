# frozen_string_literal: true

RSpec.describe Magick::Image, "#add_compose_mask" do
  it "works" do
    image = described_class.new(20, 20)
    mask = described_class.new(20, 20)

    expect { image.add_compose_mask(mask) }.not_to raise_error
    expect { image.delete_compose_mask }.not_to raise_error
    expect { image.add_compose_mask(mask) }.not_to raise_error
    expect { image.add_compose_mask(mask) }.not_to raise_error
    expect { image.delete_compose_mask }.not_to raise_error
    expect { image.delete_compose_mask }.not_to raise_error

    mask = described_class.new(10, 10)
    expect { image.add_compose_mask(mask) }.to raise_error(ArgumentError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    mask = Magick::ImageList.new
    mask.new_image(20, 20)

    expect { image.add_compose_mask(mask) }.not_to raise_error
  end

  it 'raises an error when ImageMagick runs out of resources' do
    image = described_class.new(20, 20)
    mask = described_class.new(20, 20)

    expect { without_resources { image.add_compose_mask(mask) } }.to raise_error(Magick::ImageMagickError)
  end

  it 'keeps the image usable when ImageMagick runs out of resources' do
    image = described_class.new(20, 20) { |options| options.background_color = 'red' }
    mask = described_class.new(20, 20)
    source = described_class.new(20, 20) { |options| options.background_color = 'blue' }

    expect { without_resources { image.add_compose_mask(mask) } }.to raise_error(Magick::ImageMagickError)
    result = image.composite(source, 0, 0, Magick::OverCompositeOp)
    expect(result.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('blue'))
  end

  it 'keeps the mask and the image usable when deleting the mask runs out of resources', if: Gem::Version.new(Magick::IMAGEMAGICK_VERSION) >= Gem::Version.new('7.0.0') do
    image = described_class.new(20, 20) { |options| options.background_color = 'red' }
    image.add_compose_mask(described_class.new(20, 20) { |options| options.background_color = 'black' })
    source = described_class.new(20, 20) { |options| options.background_color = 'blue' }

    expect { without_resources { image.delete_compose_mask } }.to raise_error(Magick::ImageMagickError)
    result = image.composite(source, 0, 0, Magick::OverCompositeOp)
    expect(result.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end

  it 'keeps the composite mask when replacing it runs out of resources', if: Gem::Version.new(Magick::IMAGEMAGICK_VERSION) >= Gem::Version.new('7.0.0') do
    image = described_class.new(2, 1) { |options| options.background_color = 'none' }
    image.add_compose_mask(described_class.new(2, 1) { |options| options.background_color = 'black' })
    mask = described_class.new(2, 1)
    source = described_class.new(2, 1) { |options| options.background_color = '#123456' }
    draw = Magick::Draw.new
    draw.composite(0, 0, 2, 1, image)

    expect { without_resources { image.add_compose_mask(mask) } }.to raise_error(Magick::ImageMagickError)
    result = image.composite(source, 0, 0, Magick::OverCompositeOp)
    expect(result.pixel_color(0, 0)).to eq(image.pixel_color(0, 0))
  end

  it 'keeps the mask when it deletes the composite mask' do
    image = described_class.new(2, 1) { |options| options.background_color = 'red' }
    mask = described_class.new(2, 1)
    mask.pixel_color(1, 0, 'black')
    image.mask(mask)
    image.add_compose_mask(described_class.new(2, 1) { |options| options.background_color = 'black' })
    source = described_class.new(2, 1) { |options| options.background_color = 'blue' }

    image.delete_compose_mask
    result = image.composite(source, 0, 0, Magick::OverCompositeOp)

    changed = (0..1).map { |x| result.pixel_color(x, 0).blue > Magick::QuantumRange / 2 }
    expect(changed).to eq([false, true])
  end

  it 'needs no resources to delete a composite mask that the image does not have' do
    image = described_class.new(20, 20)

    expect { without_resources { image.delete_compose_mask } }.not_to raise_error
  end

  it 'keeps the file size of the image' do
    image = described_class.read(File.join(IMAGES_DIR, 'Flower_Hat.jpg')).first
    filesize = image.filesize

    image.add_compose_mask(described_class.new(image.columns, image.rows))

    expect(image.filesize).to eq(filesize)
  end

  # ImageMagick 7 blends a masked pixel of an opaque image wrongly.
  def expect_white_changed_and_black_kept(mask)
    image = described_class.new(2, 1) { |options| options.background_color = 'none' }
    source = described_class.new(2, 1) { |options| options.background_color = '#123456' }
    unmasked = image.composite(source, 0, 0, Magick::OverCompositeOp)
    image.add_compose_mask(mask)
    result = image.composite(source, 0, 0, Magick::OverCompositeOp)

    expect(result.pixel_color(0, 0)).to eq(unmasked.pixel_color(0, 0))
    expect(result.pixel_color(1, 0)).to eq(image.pixel_color(1, 0))
  end

  it 'lets the white pixels of the mask change and keeps the black ones' do
    mask = described_class.new(2, 1)
    mask.pixel_color(1, 0, 'black')

    expect_white_changed_and_black_kept(mask)
  end

  it 'ignores the masks of the mask image' do
    mask = described_class.new(2, 1)
    mask.pixel_color(1, 0, 'black')
    mask.mask(described_class.new(2, 1) { |options| options.background_color = 'white' })

    expect_white_changed_and_black_kept(mask)
  end

  it 'ignores the composite mask of the mask image' do
    mask = described_class.new(2, 1)
    mask.pixel_color(1, 0, 'black')
    mask.add_compose_mask(described_class.new(2, 1) { |options| options.background_color = 'black' })

    expect_white_changed_and_black_kept(mask)
  end
end

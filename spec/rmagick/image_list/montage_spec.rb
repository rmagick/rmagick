# frozen_string_literal: true

RSpec.describe Magick::ImageList, "#montage" do
  def assert_same_image(expected_image_path, image_object, delta: 0.01)
    expected = Magick::Image.read(expected_image_path).first
    _, error = expected.compare_channel(image_object, Magick::MeanSquaredErrorMetric)
    expect(error).to be_within(delta).of(0.0)
  end

  it "works" do
    image_list1 = described_class.new { |info| info.depth = 16 }

    image_list1.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    image_list2 = image_list1.copy

    montage = image_list2.montage do |options|
      options.background_color = Magick::Pixel.new(Magick::QuantumRange, 0, 0)
      options.background_color = 'blue'
      options.border_color = Magick::Pixel.new(0, 0, 0)
      options.border_color = 'red'
      options.border_width = 2
      options.compose = Magick::OverCompositeOp
      options.filename = 'test.png'
      options.fill = 'green'
      options.font = Magick.fonts.first.name
      options.frame = '20x20+4+4'
      options.frame = Magick::Geometry.new(20, 20, 4, 4)
      options.geometry = '63x60+5+5'
      options.geometry = Magick::Geometry.new(63, 60, 5, 5)
      options.gravity = Magick::SouthGravity
      options.matte_color = '#bdbdbd'
      options.matte_color = Magick::Pixel.new(Magick::QuantumRange, 0, 0)
      options.pointsize = 12
      options.shadow = true
      options.stroke = 'transparent'
      options.texture = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
      options.texture = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first
      options.tile = '4x9'
      options.tile = Magick::Geometry.new(4, 9)
      options.title = 'sample'
    end
    expect(montage).to be_instance_of(described_class)
    expect(image_list2).to eq(image_list1)

    montage_image = montage.first
    expect(montage_image.background_color).to eq('#00000000FFFFFFFF')
    expect(montage_image.border_color).to eq('#FFFF00000000FFFF')

    # test illegal option arguments
    # looks like IM doesn't diagnose invalid geometry args
    # to tile= and geometry=
    expect do
      montage = image_list2.montage { |options| options.background_color = 2 }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.border_color = 2 }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.border_width = [2] }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.compose = 2 }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.filename = 2 }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.fill = 2 }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.font = 2 }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.gravity = 2 }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.matte_color = 2 }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.pointsize = 'x' }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(TypeError)
    expect do
      montage = image_list2.montage { |options| options.stroke = 'x' }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(ArgumentError)
    expect do
      montage = image_list2.montage { |options| options.texture = 'x' }
      expect(image_list2).to eq(image_list1)
    end.to raise_error(NoMethodError)
  end

  it "raises an error when images is not set" do
    image_list = described_class.new

    image_list.instance_variable_set(:@images, nil)
    expect { image_list.montage }.to raise_error(Magick::ImageMagickError)
  end

  it 'montages the image' do
    imagelist = described_class.new(IMAGES_DIR + '/Flower_Hat.jpg')

    new_imagelist = imagelist.montage do |options|
      options.border_width = 100
      options.border_color = 'red'
      options.background_color = 'blue'
      options.matte_color = 'yellow'
      options.frame = '10x10'
      options.gravity = Magick::CenterGravity
    end

    # montage ../../doc/ex/images/Flower_Hat.jpg -border 100x -bordercolor red -mattecolor yellow -background blue -frame 10x10 -gravity Center expected/montage_border_color.jpg
    assert_same_image(File.join(FIXTURE_PATH, 'montage_border_color.jpg'), new_imagelist.first)
  end

  it 'does not change the images of the list' do
    image_list = described_class.new
    image_list << Magick::Image.new(2, 2) << Magick::Image.new(2, 2)
    image_list[1].compose = Magick::MultiplyCompositeOp
    attributes = -> { image_list.to_a.map { |image| [image.background_color, image.border_color, image.matte_color, image.gravity, image.compose] } }
    before = attributes.call

    image_list.montage do |options|
      options.background_color = 'pink'
      options.border_color = 'blue'
      options.matte_color = 'green'
      options.gravity = Magick::SouthGravity
      options.compose = Magick::OverCompositeOp
    end

    expect(attributes.call).to eq(before)
  end

  it 'does not let an image be destroyed while it copies the images or makes the montage' do
    image_list = described_class.new
    image_list << Magick::Image.new(1, 1) << Magick::Image.new(1, 1)
    errors = []
    destroy = lambda do
      image_list[1].destroy!
    rescue RuntimeError => e
      errors << e.message
    end

    during_call(destroy, destroy, destroy) { image_list.montage }

    expect(errors).to eq(['object is in use by another fiber'] * 3)
    expect(image_list[1]).not_to be_destroyed
  end

  it 'does not let the options be changed while it copies the images' do
    image_list = described_class.new
    image_list << Magick::Image.new(1, 1) << Magick::Image.new(1, 1)
    options = nil
    error = nil
    change = lambda do
      options.background_color = 'red'
    rescue RuntimeError => e
      error = e.message
    end

    during_call(change) { image_list.montage { |montage| options = montage } }

    expect(error).to eq('object is in use by another fiber')
  end

  it 'raises ImageMagickError for an image with no columns on ImageMagick 6', if: Gem::Version.new(Magick::IMAGEMAGICK_VERSION) < Gem::Version.new('7.0.0') do
    image_list = described_class.new
    image_list << Magick::Image.new(0, 5)

    expect { image_list.montage }.to raise_error(Magick::ImageMagickError)
  end
end

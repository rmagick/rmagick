# frozen_string_literal: true

RSpec.describe Magick::Image, '#watermark' do
  it 'works' do
    image = described_class.new(20, 20)
    mark = described_class.new(5, 5)

    expect { image.watermark(mark) }.not_to raise_error
    expect { image.watermark(mark, 0.50) }.not_to raise_error
    expect { image.watermark(mark, '50%') }.not_to raise_error
    expect { image.watermark(mark, 0.50, 0.50) }.not_to raise_error
    expect { image.watermark(mark, 0.50, '50%') }.not_to raise_error
    expect { image.watermark(mark, 0.50, 0.50, 10) }.not_to raise_error
    expect { image.watermark(mark, 0.50, 0.50, 10, 10) }.not_to raise_error
    expect { image.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity) }.not_to raise_error
    expect { image.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 10) }.not_to raise_error
    expect { image.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 10, 10) }.not_to raise_error

    expect { image.watermark }.to raise_error(ArgumentError)
    expect { image.watermark(mark, 'x') }.to raise_error(ArgumentError)
    expect { image.watermark(mark, 0.50, 'x') }.to raise_error(ArgumentError)
    expect { image.watermark(mark, 0.50, '1500%') }.to raise_error(ArgumentError)
    expect { image.watermark(mark, 0.50, 0.50, 'x') }.to raise_error(TypeError)
    expect { image.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 'x') }.to raise_error(TypeError)
    expect { image.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 10, 'x') }.to raise_error(TypeError)

    mark.destroy!
    expect { image.watermark(mark) }.to raise_error(Magick::DestroyedImageError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.watermark(image_list) }.not_to raise_error
    expect { image.watermark(image_list) }.not_to raise_error
    expect { image.watermark(image_list, 0.50) }.not_to raise_error
    expect { image.watermark(image_list, '50%') }.not_to raise_error
    expect { image.watermark(image_list, 0.50, 0.50) }.not_to raise_error
    expect { image.watermark(image_list, 0.50, '50%') }.not_to raise_error
    expect { image.watermark(image_list, 0.50, 0.50, 10) }.not_to raise_error
    expect { image.watermark(image_list, 0.50, 0.50, 10, 10) }.not_to raise_error
    expect { image.watermark(image_list, 0.50, 0.50, Magick::NorthEastGravity) }.not_to raise_error
    expect { image.watermark(image_list, 0.50, 0.50, Magick::NorthEastGravity, 10) }.not_to raise_error
    expect { image.watermark(image_list, 0.50, 0.50, Magick::NorthEastGravity, 10, 10) }.not_to raise_error
  end

  it 'does not change a frozen overlay' do
    image = described_class.new(20, 20)
    overlay = described_class.new(5, 5).freeze

    image.watermark(overlay, 0.50, 0.50)

    expect(overlay.artifact('compose:args')).to be(nil)
    expect(overlay.geometry).to be(nil)
  end

  it 'uses the brightness and saturation' do
    image = described_class.new(4, 4) { |options| options.background_color = 'gray50' }
    mark = described_class.new(4, 4) { |options| options.background_color = 'gray75' }

    bright = image.watermark(mark, 1.0, 1.0)
    dark = image.watermark(mark, 0.10, 1.0)

    expect(dark.pixel_color(0, 0).intensity).to be < bright.pixel_color(0, 0).intensity
  end
end

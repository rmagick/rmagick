# frozen_string_literal: true

RSpec.describe Magick::Image, '#resize!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.resize!(2)
    expect(result).to be(image)

    image.freeze
    expect { image.resize!(0.50) }.to raise_error(FrozenError)
  end

  # ImageMagick returns a copy that shares the pixel cache for the same size,
  # and the copy needs a cache of its own to replace the image.
  it 'keeps the image and frees the copy when ImageMagick runs out of resources' do
    GC.start
    baseline = Magick.resource_usage(:memory)
    image = described_class.new(200, 200) { |options| options.background_color = 'red' }
    pixels = image.export_pixels

    expect { without_resources { image.resize!(200, 200) } }.to raise_error(Magick::ImageMagickError)
    expect(image.export_pixels).to eq(pixels)
    image.destroy!
    3.times { GC.start }

    expect(Magick.resource_usage(:memory)).to be <= baseline
  end
end

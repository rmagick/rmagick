# frozen_string_literal: true

RSpec.describe Magick::Image, '#export_pixels_to_str' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.export_pixels_to_str
    expect(result).to be_instance_of(String)
    expect(result.length).to eq(image.columns * image.rows * 'RGB'.length)

    expect { image.export_pixels_to_str(0) }.not_to raise_error
    expect { image.export_pixels_to_str(0, 0) }.not_to raise_error
    expect { image.export_pixels_to_str(0, 0, 10) }.not_to raise_error
    expect { image.export_pixels_to_str(0, 0, 10, 10) }.not_to raise_error

    result = image.export_pixels_to_str(0, 0, 10, 10, 'RGBA')
    expect(result.length).to eq(10 * 10 * 'RGBA'.length)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I')
    expect(result.length).to eq(10 * 10 * 'I'.length)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::CharPixel)
    expect(result.length).to eq(10 * 10 * 1)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::ShortPixel)
    expect(result.length).to eq(10 * 10 * 2)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::LongPixel)
    expect(result.length).to eq(10 * 10 * 4)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::FloatPixel)
    expect(result.length).to eq(10 * 10 * 4)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::DoublePixel)
    expect(result.length).to eq(10 * 10 * 8)

    expect { image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel) }.not_to raise_error

    # too many arguments
    expect { image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel, 1) }.to raise_error(ArgumentError)
    # last arg s/b StorageType
    expect { image.export_pixels_to_str(0, 0, 10, 10, 'I', 2) }.to raise_error(TypeError)
  end

  # Regression: LongPixel reserved sizeof(unsigned long) per element, but
  # ImageMagick's ExportLongPixel writes unsigned int. On LP64 that left the
  # second half of the string as whatever the heap held, and a caller reading it
  # back as native longs got the wrong values as well.
  it 'fills the whole buffer for LongPixel' do
    image = described_class.new(8, 8) { |options| options.background_color = 'white' }

    result = image.export_pixels_to_str(0, 0, 8, 8, 'RGB', Magick::LongPixel)

    expect(result.bytesize).to eq(8 * 8 * 3 * 4)
    expect(result.unpack('L*')).to all(eq(0xffffffff))
  end

  # Regression: cols * rows * map_length (and that times the storage-type size)
  # is computed in unsigned arithmetic. A geometry that overflows it used to
  # under-allocate the string buffer, so ImageMagick wrote out of bounds
  # (SIGSEGV / heap corruption). It must raise RangeError instead.
  it 'raises RangeError when the geometry overflows the buffer size' do
    image = described_class.new(8, 8)

    expect { image.export_pixels_to_str(0, 0, 2**32, 2**32, 'R', Magick::CharPixel) }.to raise_error(RangeError)
    expect { image.export_pixels_to_str(0, 0, 2**61, 1, 'R', Magick::DoublePixel) }.to raise_error(RangeError)
  end
end

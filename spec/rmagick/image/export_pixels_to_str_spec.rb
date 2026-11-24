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

  # Regression: a geometry this large used to overflow cols * rows * map_length
  # (and that times the storage-type size) and under-allocate the string
  # buffer, so ImageMagick wrote out of bounds (SIGSEGV / heap corruption). The
  # bounds check now rejects it first.
  it 'raises RangeError when the geometry overflows the buffer size' do
    image = described_class.new(8, 8)

    expect { image.export_pixels_to_str(0, 0, 2**32, 2**32, 'R', Magick::CharPixel) }.to raise_error(RangeError)
    expect { image.export_pixels_to_str(0, 0, 2**61, 1, 'R', Magick::DoublePixel) }.to raise_error(RangeError)
  end

  it 'reads the map when the GC compacts while it runs', if: GCCompaction.moves_arguments? do
    image = described_class.new(4, 4) { |options| options.background_color = 'red' }
    expected = image.export_pixels_to_str(0, 0, 4, 4, 'RGB')
    results = []

    with_gc_compaction do
      10.times { results << image.export_pixels_to_str(0, 0, 4, 4, ToStrDuck.new('RGB')) }
    end

    expect(results).to eq([expected] * 10)
  end

  it 'raises RangeError for a rectangle outside the image' do
    image = described_class.new(4, 4)

    expect { image.export_pixels_to_str(-1, 0, 2, 1, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels_to_str(0, -1, 1, 2, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels_to_str(0, 0, 5, 1, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels_to_str(0, 0, 1, 5, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels_to_str(4, 4, 1, 1, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels_to_str(0, 0, -1, 1, 'R') }.to raise_error(RangeError)
    expect(image.export_pixels_to_str(3, 3, 1, 1, 'R').bytesize).to eq(1)
  end

  it 'raises ArgumentError for an empty rectangle' do
    image = described_class.new(4, 4)

    expect { image.export_pixels_to_str(0, 0, 0, 1, 'R') }.to raise_error(ArgumentError)
    expect { image.export_pixels_to_str(0, 0, 1, 0, 'R') }.to raise_error(ArgumentError)
    expect { image.export_pixels_to_str(0, 1, 0) }.to raise_error(ArgumentError)
    expect { image.export_pixels_to_str(-1, 0, 0, 1, 'R') }.to raise_error(ArgumentError)
  end

  it 'raises RangeError for an offset whose default size goes past the image' do
    image = described_class.new(4, 4)

    expect { image.export_pixels_to_str(1) }.to raise_error(RangeError)
    expect { image.export_pixels_to_str(0, 1) }.to raise_error(RangeError)
    expect { image.export_pixels_to_str(1, 1, 2) }.to raise_error(RangeError)
    expect(image.export_pixels_to_str(0, 0).bytesize).to eq(4 * 4 * 3)
    expect(image.export_pixels_to_str(1, 0, 3).bytesize).to eq(3 * 4 * 3)
  end

  it 'takes the default size from the image after converting the arguments' do
    image = described_class.new(4, 4)
    x = Object.new
    x.define_singleton_method(:to_int) do
      image.crop!(0, 0, 2, 2)
      0
    end

    expect(image.export_pixels_to_str(x).bytesize).to eq(2 * 2 * 3)
  end
end

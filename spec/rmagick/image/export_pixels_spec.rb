# frozen_string_literal: true

RSpec.describe Magick::Image, '#export_pixels' do
  def fimport(image, pixels, type)
    image = Magick::Image.new(image.columns, image.rows)
    image.import_pixels(0, 0, image.columns, image.rows, 'RGB', pixels, type)
    _, diff = image.compare_channel(image, Magick::MeanAbsoluteErrorMetric)
    expect(diff).to be_within(50.0).of(0.0)
  end

  it 'works' do
    image = described_class.new(20, 20)

    result = image.export_pixels
    expect(result).to be_instance_of(Array)
    expect(result.length).to eq(image.columns * image.rows * 'RGB'.length)
    expect(result).to all(be_kind_of(Integer))

    expect { image.export_pixels(0) }.not_to raise_error
    expect { image.export_pixels(0, 0) }.not_to raise_error
    expect { image.export_pixels(0, 0, 10) }.not_to raise_error
    expect { image.export_pixels(0, 0, 10, 10) }.not_to raise_error

    result = image.export_pixels(0, 0, 10, 10, 'RGBA')
    expect(result.length).to eq(10 * 10 * 'RGBA'.length)

    result = image.export_pixels(0, 0, 10, 10, 'I')
    expect(result.length).to eq(10 * 10 * 'I'.length)

    # too many arguments
    expect { image.export_pixels(0, 0, 10, 10, 'I', 2) }.to raise_error(ArgumentError)
  end

  # Regression: a geometry this large used to overflow cols * rows * map_length
  # and under-allocate the pixel buffer, so ImageMagick wrote out of bounds
  # (SIGSEGV / heap corruption). The bounds check now rejects it first.
  it 'raises RangeError when the geometry overflows the buffer size' do
    image = described_class.new(8, 8)

    expect { image.export_pixels(0, 0, 2**32, 2**32, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels(0, 0, 2**48, 2**16, 'R') }.to raise_error(RangeError)
  end

  it 'works with float types' do
    image = described_class.read(File.join(IMAGES_DIR, 'Flower_Hat.jpg')).first

    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGB')
    fpixels = pixels.map { |pixel| pixel.to_f / Magick::QuantumRange }
    packed_pixels = fpixels.pack('F*')
    fimport(image, packed_pixels, Magick::FloatPixel)

    packed_pixels = fpixels.pack('D*')
    fimport(image, packed_pixels, Magick::DoublePixel)
  end

  it 'reads NaN and a value out of the range of int' do
    image = described_class.new(3, 1)
    image.import_pixels(0, 0, 3, 1, 'R', [1e10, -1e10, Float::NAN])

    if Magick::Magick_features.include?('HDRI')
      expected = [10_000_000_000, -10_000_000_000, 0]
      expect(image.get_pixels(0, 0, 3, 1).map(&:red)).to eq(expected)
    else
      expected = [Magick::QuantumRange, 0, 0]
    end
    expect(image.export_pixels(0, 0, 3, 1, 'R')).to eq(expected)
  end

  it 'reads the map when the GC compacts while it runs', if: GCCompaction.moves_arguments? do
    image = described_class.new(4, 4) { |options| options.background_color = 'red' }
    expected = image.export_pixels(0, 0, 4, 4, 'RGB')
    results = []

    with_gc_compaction do
      30.times { results << image.export_pixels(0, 0, 4, 4, ToStrDuck.new('RGB')) }
    end

    expect(results).to eq([expected] * 30)
  end

  it 'raises RangeError for a rectangle outside the image' do
    image = described_class.new(4, 4)

    expect { image.export_pixels(-1, 0, 2, 1, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels(0, -1, 1, 2, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels(0, 0, 5, 1, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels(0, 0, 1, 5, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels(4, 4, 1, 1, 'R') }.to raise_error(RangeError)
    expect { image.export_pixels(0, 0, -1, 1, 'R') }.to raise_error(RangeError)
    expect(image.export_pixels(3, 3, 1, 1, 'R').length).to eq(1)
  end

  it 'raises ArgumentError for an empty rectangle' do
    image = described_class.new(4, 4)

    expect { image.export_pixels(0, 0, 0, 1, 'R') }.to raise_error(ArgumentError)
    expect { image.export_pixels(0, 0, 1, 0, 'R') }.to raise_error(ArgumentError)
    expect { image.export_pixels(0, 1, 0) }.to raise_error(ArgumentError)
    expect { image.export_pixels(-1, 0, 0, 1, 'R') }.to raise_error(ArgumentError)
  end

  it 'raises RangeError for an offset whose default size goes past the image' do
    image = described_class.new(4, 4)

    expect { image.export_pixels(1) }.to raise_error(RangeError)
    expect { image.export_pixels(0, 1) }.to raise_error(RangeError)
    expect { image.export_pixels(1, 1, 2) }.to raise_error(RangeError)
    expect(image.export_pixels(0, 0).length).to eq(4 * 4 * 3)
    expect(image.export_pixels(1, 0, 3).length).to eq(3 * 4 * 3)
  end

  it 'takes the default size from the image after converting the arguments' do
    image = described_class.new(4, 4)
    x = Object.new
    x.define_singleton_method(:to_int) do
      image.crop!(0, 0, 2, 2)
      0
    end

    expect(image.export_pixels(x).length).to eq(2 * 2 * 3)
  end
end

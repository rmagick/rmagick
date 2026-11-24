# frozen_string_literal: true

RSpec.describe Magick::Image, '#dispatch' do
  it 'expects exactly 5 or 6 arguments' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    expect { image.dispatch }.to raise_error(ArgumentError)
    expect { image.dispatch(0) }.to raise_error(ArgumentError)
    expect { image.dispatch(0, 0) }.to raise_error(ArgumentError)
    expect { image.dispatch(0, 0, image.columns) }.to raise_error(ArgumentError)
    expect do
      image.dispatch(0, 0, image.columns, image.rows)
    end.to raise_error(ArgumentError)
    expect do
      image.dispatch(0, 0, 20, 20, 'RGBA', false, false)
    end.to raise_error(ArgumentError)
  end

  # Regression: the map was measured with RSTRING_LEN while ImageMagick sizes
  # its own work with strlen(map), so an embedded NUL made RMagick allocate more
  # elements than ImageMagick filled and return the remainder, uninitialised
  # heap and all, as Integers.
  it 'rejects a map containing a NUL byte' do
    image = described_class.new(8, 8) { |options| options.background_color = 'white' }

    expect { image.dispatch(0, 0, 8, 8, "RGB\0\0\0") }.to raise_error(ArgumentError)
    expect(image.dispatch(0, 0, 8, 8, 'RGB').length).to eq(8 * 8 * 3)
  end

  # Regression: a geometry this large used to overflow columns * rows * map_length
  # and under-allocate the pixel buffer, so ImageMagick wrote out of bounds
  # (SIGSEGV / heap corruption). The bounds check now rejects it first.
  it 'raises RangeError when the geometry overflows the buffer size' do
    image = described_class.new(8, 8)

    expect { image.dispatch(0, 0, 2**32, 2**32, 'R') }.to raise_error(RangeError)
    expect { image.dispatch(0, 0, 2**48, 2**16, 'R') }.to raise_error(RangeError)
  end

  it "returns an empty array when ImageMagick rejects the map" do
    image = described_class.new(2, 2)

    expect(image.dispatch(0, 0, 1, 1, "Z")).to eq([])
  end

  it 'reads the map when the GC compacts while it runs', if: GCCompaction.moves_arguments? do
    image = described_class.new(4, 4) { |options| options.background_color = 'red' }
    expected = image.dispatch(0, 0, 4, 4, 'RGB')
    results = []

    with_gc_compaction do
      10.times { results << image.dispatch(0, 0, 4, 4, ToStrDuck.new('RGB')) }
    end

    expect(results).to eq([expected] * 10)
  end

  it 'raises RangeError for a rectangle outside the image' do
    image = described_class.new(4, 4)

    expect { image.dispatch(-1, 0, 2, 1, 'R') }.to raise_error(RangeError)
    expect { image.dispatch(0, -1, 1, 2, 'R') }.to raise_error(RangeError)
    expect { image.dispatch(0, 0, 5, 1, 'R') }.to raise_error(RangeError)
    expect { image.dispatch(0, 0, 1, 5, 'R') }.to raise_error(RangeError)
    expect { image.dispatch(4, 4, 1, 1, 'R') }.to raise_error(RangeError)
    expect { image.dispatch(0, 0, -1, 1, 'R') }.to raise_error(RangeError)
    expect(image.dispatch(3, 3, 1, 1, 'R').length).to eq(1)
  end
end

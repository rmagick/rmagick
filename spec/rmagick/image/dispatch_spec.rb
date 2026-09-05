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

  # Regression: columns * rows * map_length is computed in unsigned arithmetic.
  # A geometry that overflows it used to under-allocate the pixel buffer, so
  # ImageMagick wrote out of bounds (SIGSEGV / heap corruption). It must raise
  # RangeError instead.
  it 'raises RangeError when the geometry overflows the buffer size' do
    image = described_class.new(8, 8)

    expect { image.dispatch(0, 0, 2**32, 2**32, 'R') }.to raise_error(RangeError)
    expect { image.dispatch(0, 0, 2**48, 2**16, 'R') }.to raise_error(RangeError)
  end
end

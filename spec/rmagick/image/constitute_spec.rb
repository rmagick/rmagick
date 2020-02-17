RSpec.describe Magick::Image, '#constitute' do
  it 'returns an equivalent image to the given pixels' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGBA')

    result = described_class.constitute(image.columns, image.rows, 'RGBA', pixels)

    expect(result.export_pixels).to eq(image.export_pixels)
  end

  it 'allows constituting with RGBA quantum (integer) pixel values' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    # [R, G, B, A, R, G, B, A, ...]
    pixels = [1] * 4 * image.columns * image.rows

    result = described_class.constitute(image.columns, image.rows, 'RGBA', pixels)

    result_pixels = result.dispatch(0, 0, image.columns, image.rows, 'RGBA')
    expect(result_pixels).to all eq(1)
  end

  it 'allows constituting with RGBA scale (float) pixel values' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    # [R, G, B, A, R, G, B, A, ...]
    pixels = [1.0] * 4 * image.columns * image.rows

    result = described_class.constitute(image.columns, image.rows, 'RGBA', pixels)

    result_pixels = result.dispatch(0, 0, image.columns, image.rows, 'RGBA')
    expect(result_pixels).to all eq(65_535)
  end

  it 'raises an error when invalid RGBA pixel values are given' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    pixels = ['x'] * (4 * image.columns * image.rows)
    expected_message = 'element 0 in pixel array is String, must be numeric'

    expect { described_class.constitute(image.columns, image.rows, 'RGBA', pixels) }
      .to raise_error(TypeError, expected_message)
  end

  it 'raises an error when 0 is passed for columns' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGBA')
    expected_message = 'width and height must be greater than zero'

    expect { described_class.constitute(0, image.rows, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end

  it 'raises an error when a negative number is passed for columns' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGBA')
    expected_message = 'width and height must be greater than zero'

    expect { described_class.constitute(-3, image.rows, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end

  it 'raises an error when 0 is passed for rows' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGBA')
    expected_message = 'width and height must be greater than zero'

    expect { described_class.constitute(image.columns, 0, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end

  it 'raises an error when a negative number is passed for rows' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGBA')
    expected_message = 'width and height must be greater than zero'

    expect { described_class.constitute(image.columns, -3, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end

  it 'raises an error given the wrong number of array elements' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGBA')
    expected_message = 'wrong number of array elements (60960 for 72)'

    expect { described_class.constitute(3, 6, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end
end

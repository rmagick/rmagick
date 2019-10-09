RSpec.describe Magick::Image, '#constitute' do
  let(:img) { Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first }
  let(:pixels) { img.export_pixels(0, 0, img.columns, img.rows, 'RGBA') }

  it 'returns an equivalent image to the given pixels' do
    result = Magick::Image.constitute(img.columns, img.rows, 'RGBA', pixels)

    expect(result.export_pixels).to eq(img.export_pixels)
  end

  it 'allows constituting with RGBA quantum (integer) pixel values' do
    # [R, G, B, A, R, G, B, A, ...]
    pixels = [1] * 4 * img.columns * img.rows

    result = Magick::Image.constitute(img.columns, img.rows, 'RGBA', pixels)

    result_pixels = result.dispatch(0, 0, img.columns, img.rows, 'RGBA')
    expect(result_pixels).to all eq(1)
  end

  it 'allows constituting with RGBA scale (float) pixel values' do
    # [R, G, B, A, R, G, B, A, ...]
    pixels = [1.0] * 4 * img.columns * img.rows

    result = Magick::Image.constitute(img.columns, img.rows, 'RGBA', pixels)

    result_pixels = result.dispatch(0, 0, img.columns, img.rows, 'RGBA')
    expect(result_pixels).to all eq(65_535)
  end

  it 'raises an error when invalid RGBA pixel values are given' do
    pixels = ['x'] * (4 * img.columns * img.rows)
    expected_message = 'element 0 in pixel array is String, must be numeric'

    expect { Magick::Image.constitute(img.columns, img.rows, 'RGBA', pixels) }
      .to raise_error(TypeError, expected_message)
  end

  it 'raises an error when 0 is passed for columns' do
    expected_message = 'width and height must be greater than zero'

    expect { Magick::Image.constitute(0, img.rows, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end

  it 'raises an error when a negative number is passed for columns' do
    expected_message = 'width and height must be greater than zero'

    expect { Magick::Image.constitute(-3, img.rows, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end

  it 'raises an error when 0 is passed for rows' do
    expected_message = 'width and height must be greater than zero'

    expect { Magick::Image.constitute(img.columns, 0, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end

  it 'raises an error when a negative number is passed for rows' do
    expected_message = 'width and height must be greater than zero'

    expect { Magick::Image.constitute(img.columns, -3, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end

  it 'raises an error given the wrong number of array elements' do
    expected_message = 'wrong number of array elements (60960 for 72)'

    expect { Magick::Image.constitute(3, 6, 'RGBA', pixels) }
      .to raise_error(ArgumentError, expected_message)
  end
end

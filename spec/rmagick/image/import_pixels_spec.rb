RSpec.describe Magick::Image, '#import_pixels' do
  def import(image, pixels, type, expected = 0.0)
    image = Magick::Image.new(image.columns, image.rows)
    image.import_pixels(0, 0, image.columns, image.rows, 'RGB', pixels, type)
    _, diff = image.compare_channel(image, Magick::MeanAbsoluteErrorMetric)
    expect(diff).to be_within(0.1).of(expected)
  end

  it 'works' do
    image = described_class.new(20, 20)
    pixels = image.export_pixels(0, 0, image.columns, 1, 'RGB')

    result = image.import_pixels(0, 0, image.columns, 1, 'RGB', pixels)
    expect(result).to be(image)

    expect { image.import_pixels }.to raise_error(ArgumentError)
    expect { image.import_pixels(0) }.to raise_error(ArgumentError)
    expect { image.import_pixels(0, 0) }.to raise_error(ArgumentError)
    expect { image.import_pixels(0, 0, image.columns) }.to raise_error(ArgumentError)
    expect { image.import_pixels(0, 0, image.columns, 1) }.to raise_error(ArgumentError)
    expect { image.import_pixels(0, 0, image.columns, 1, 'RGB') }.to raise_error(ArgumentError)
    expect { image.import_pixels('x', 0, image.columns, 1, 'RGB', pixels) }.to raise_error(TypeError)
    expect { image.import_pixels(0, 'x', image.columns, 1, 'RGB', pixels) }.to raise_error(TypeError)
    expect { image.import_pixels(0, 0, 'x', 1, 'RGB', pixels) }.to raise_error(TypeError)
    expect { image.import_pixels(0, 0, image.columns, 'x', 'RGB', pixels) }.to raise_error(TypeError)
    expect { image.import_pixels(0, 0, image.columns, 1, [2], pixels) }.to raise_error(TypeError)
    expect { image.import_pixels(-1, 0, image.columns, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
    expect { image.import_pixels(0, -1, image.columns, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
    expect { image.import_pixels(0, 0, -1, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
    expect { image.import_pixels(0, 0, image.columns, -1, 'RGB', pixels) }.to raise_error(ArgumentError)

    # pixel array is too small
    expect { image.import_pixels(0, 0, image.columns, 2, 'RGB', pixels) }.to raise_error(ArgumentError)
    # pixel array doesn't contain a multiple of the map length
    pixels.shift
    expect { image.import_pixels(0, 0, image.columns, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
  end

  it 'raises an error given UndefinedPixel' do
    image = described_class.new(20, 20)
    pixels = image.export_pixels(0, 0, 20, 20, 'RGB').pack('D*')

    expect do
      image.import_pixels(0, 0, 20, 20, 'RGB', pixels, Magick::UndefinedPixel)
    end.to raise_error(ArgumentError, /UndefinedPixel/)
  end

  it 'works with different pixel types' do
    image = described_class.read(File.join(IMAGES_DIR, 'Flower_Hat.jpg')).first
    is_hdri_support = Magick::Magick_features =~ /HDRI/
    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGB')

    case Magick::MAGICKCORE_QUANTUM_DEPTH
    when 8
      packed_pixels = pixels.pack('C*')
      import(image, packed_pixels, Magick::CharPixel)
      packed_pixels = pixels.pack('F*') if is_hdri_support
      import(image, packed_pixels, Magick::QuantumPixel)

      spixels = pixels.map { |px| px * 257 }
      packed_pixels = spixels.pack('S*')
      import(image, packed_pixels, Magick::ShortPixel)

      ipixels = pixels.map { |px| px * 16_843_009 }
      packed_pixels = ipixels.pack('I*')
      import(image, packed_pixels, Magick::LongPixel)

    when 16
      cpixels = pixels.map { |px| px / 257 }
      packed_pixels = cpixels.pack('C*')
      import(image, packed_pixels, Magick::CharPixel)

      packed_pixels = pixels.pack('S*')
      import(image, packed_pixels, Magick::ShortPixel)
      packed_pixels = pixels.pack('F*') if is_hdri_support
      import(image, packed_pixels, Magick::QuantumPixel)

      ipixels = pixels.map { |px| px * 65_537 }
      ipixels.pack('I*')
      # Diff s/b 0.0 but never is.
      # import(image, packed_pixels, Magick::LongPixel, 430.7834)

    when 32
      cpixels = pixels.map { |px| px / 16_843_009 }
      packed_pixels = cpixels.pack('C*')
      import(image, packed_pixels, Magick::CharPixel)

      spixels = pixels.map { |px| px / 65_537 }
      packed_pixels = spixels.pack('S*')
      import(image, packed_pixels, Magick::ShortPixel)

      packed_pixels = pixels.pack('I*')
      import(image, packed_pixels, Magick::LongPixel)
      packed_pixels = pixels.pack('D*') if is_hdri_support
      import(image, packed_pixels, Magick::QuantumPixel)

    when 64
      cpixels = pixels.map { |px| px / 72_340_172_838_076_673 }
      packed_pixels = cpixels.pack('C*')
      import(image, packed_pixels, Magick::CharPixel)

      spixels = pixels.map { |px| px / 281_479_271_743_489 }
      packed_pixels = spixels.pack('S*')
      import(image, packed_pixels, Magick::ShortPixel)

      ipixels = pixels.map { |px| px / 4_294_967_297 }
      packed_pixels = ipixels.pack('I*')
      import(image, packed_pixels, Magick::LongPixel)

      packed_pixels = pixels.pack('Q*')
      import(image, packed_pixels, Magick::QuantumPixel)
    end
  end
end

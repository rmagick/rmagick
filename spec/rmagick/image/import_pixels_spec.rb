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
      p = pixels.pack('C*')
      import(image, p, Magick::CharPixel)
      p = pixels.pack('F*') if is_hdri_support
      import(image, p, Magick::QuantumPixel)

      spixels = pixels.collect { |px| px * 257 }
      p = spixels.pack('S*')
      import(image, p, Magick::ShortPixel)

      ipixels = pixels.collect { |px| px * 16_843_009 }
      p = ipixels.pack('I*')
      import(image, p, Magick::LongPixel)

    when 16
      cpixels = pixels.collect { |px| px / 257 }
      p = cpixels.pack('C*')
      import(image, p, Magick::CharPixel)

      p = pixels.pack('S*')
      import(image, p, Magick::ShortPixel)
      p = pixels.pack('F*') if is_hdri_support
      import(image, p, Magick::QuantumPixel)

      ipixels = pixels.collect { |px| px * 65_537 }
      ipixels.pack('I*')
      # Diff s/b 0.0 but never is.
      # import(image, p, Magick::LongPixel, 430.7834)

    when 32
      cpixels = pixels.collect { |px| px / 16_843_009 }
      p = cpixels.pack('C*')
      import(image, p, Magick::CharPixel)

      spixels = pixels.collect { |px| px / 65_537 }
      p = spixels.pack('S*')
      import(image, p, Magick::ShortPixel)

      p = pixels.pack('I*')
      import(image, p, Magick::LongPixel)
      p = pixels.pack('D*') if is_hdri_support
      import(image, p, Magick::QuantumPixel)

    when 64
      cpixels = pixels.collect { |px| px / 72_340_172_838_076_673 }
      p = cpixels.pack('C*')
      import(image, p, Magick::CharPixel)

      spixels = pixels.collect { |px| px / 281_479_271_743_489 }
      p = spixels.pack('S*')
      import(image, p, Magick::ShortPixel)

      ipixels = pixels.collect { |px| px / 4_294_967_297 }
      p = ipixels.pack('I*')
      import(image, p, Magick::LongPixel)

      p = pixels.pack('Q*')
      import(image, p, Magick::QuantumPixel)
    end
  end
end

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

  it 'works with float types' do
    image = described_class.read(File.join(IMAGES_DIR, 'Flower_Hat.jpg')).first

    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGB')
    fpixels = pixels.map { |pixel| pixel.to_f / Magick::QuantumRange }
    packed_pixels = fpixels.pack('F*')
    fimport(image, packed_pixels, Magick::FloatPixel)

    packed_pixels = fpixels.pack('D*')
    fimport(image, packed_pixels, Magick::DoublePixel)
  end
end

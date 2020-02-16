RSpec.describe Magick::Image, '#export_pixels' do
  def fimport(image, pixels, type)
    img = Magick::Image.new(image.columns, image.rows)
    img.import_pixels(0, 0, image.columns, image.rows, 'RGB', pixels, type)
    _, diff = img.compare_channel(image, Magick::MeanAbsoluteErrorMetric)
    expect(diff).to be_within(50.0).of(0.0)
  end

  it 'works' do
    img = described_class.new(20, 20)

    res = img.export_pixels
    expect(res).to be_instance_of(Array)
    expect(res.length).to eq(img.columns * img.rows * 'RGB'.length)
    expect(res).to all(be_kind_of(Integer))

    expect { img.export_pixels(0) }.not_to raise_error
    expect { img.export_pixels(0, 0) }.not_to raise_error
    expect { img.export_pixels(0, 0, 10) }.not_to raise_error
    expect { img.export_pixels(0, 0, 10, 10) }.not_to raise_error
    expect do
      res = img.export_pixels(0, 0, 10, 10, 'RGBA')
      expect(res.length).to eq(10 * 10 * 'RGBA'.length)
    end.not_to raise_error
    expect do
      res = img.export_pixels(0, 0, 10, 10, 'I')
      expect(res.length).to eq(10 * 10 * 'I'.length)
    end.not_to raise_error

    # too many arguments
    expect { img.export_pixels(0, 0, 10, 10, 'I', 2) }.to raise_error(ArgumentError)
  end

  it 'works with float types' do
    image = described_class.read(File.join(IMAGES_DIR, 'Flower_Hat.jpg')).first

    pixels = image.export_pixels(0, 0, image.columns, image.rows, 'RGB')
    fpixels = pixels.collect { |p| p.to_f / Magick::QuantumRange }
    p = fpixels.pack('F*')
    fimport(image, p, Magick::FloatPixel)

    p = fpixels.pack('D*')
    fimport(image, p, Magick::DoublePixel)
  end
end

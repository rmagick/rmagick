RSpec.describe Magick::Image, '#export_pixels_to_str' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.export_pixels_to_str
    expect(res).to be_instance_of(String)
    expect(res.length).to eq(image.columns * image.rows * 'RGB'.length)

    expect { image.export_pixels_to_str(0) }.not_to raise_error
    expect { image.export_pixels_to_str(0, 0) }.not_to raise_error
    expect { image.export_pixels_to_str(0, 0, 10) }.not_to raise_error
    expect { image.export_pixels_to_str(0, 0, 10, 10) }.not_to raise_error

    res = image.export_pixels_to_str(0, 0, 10, 10, 'RGBA')
    expect(res.length).to eq(10 * 10 * 'RGBA'.length)

    res = image.export_pixels_to_str(0, 0, 10, 10, 'I')
    expect(res.length).to eq(10 * 10 * 'I'.length)

    res = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::CharPixel)
    expect(res.length).to eq(10 * 10 * 1)

    res = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::ShortPixel)
    expect(res.length).to eq(10 * 10 * 2)

    res = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::LongPixel)
    expect(res.length).to eq(10 * 10 * [1].pack('L!').length)

    res = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::FloatPixel)
    expect(res.length).to eq(10 * 10 * 4)

    res = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::DoublePixel)
    expect(res.length).to eq(10 * 10 * 8)

    expect { image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel) }.not_to raise_error

    # too many arguments
    expect { image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel, 1) }.to raise_error(ArgumentError)
    # last arg s/b StorageType
    expect { image.export_pixels_to_str(0, 0, 10, 10, 'I', 2) }.to raise_error(TypeError)
  end
end

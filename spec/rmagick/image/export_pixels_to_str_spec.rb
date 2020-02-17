RSpec.describe Magick::Image, '#export_pixels_to_str' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.export_pixels_to_str
    expect(result).to be_instance_of(String)
    expect(result.length).to eq(image.columns * image.rows * 'RGB'.length)

    expect { image.export_pixels_to_str(0) }.not_to raise_error
    expect { image.export_pixels_to_str(0, 0) }.not_to raise_error
    expect { image.export_pixels_to_str(0, 0, 10) }.not_to raise_error
    expect { image.export_pixels_to_str(0, 0, 10, 10) }.not_to raise_error

    result = image.export_pixels_to_str(0, 0, 10, 10, 'RGBA')
    expect(result.length).to eq(10 * 10 * 'RGBA'.length)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I')
    expect(result.length).to eq(10 * 10 * 'I'.length)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::CharPixel)
    expect(result.length).to eq(10 * 10 * 1)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::ShortPixel)
    expect(result.length).to eq(10 * 10 * 2)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::LongPixel)
    expect(result.length).to eq(10 * 10 * [1].pack('L!').length)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::FloatPixel)
    expect(result.length).to eq(10 * 10 * 4)

    result = image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::DoublePixel)
    expect(result.length).to eq(10 * 10 * 8)

    expect { image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel) }.not_to raise_error

    # too many arguments
    expect { image.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel, 1) }.to raise_error(ArgumentError)
    # last arg s/b StorageType
    expect { image.export_pixels_to_str(0, 0, 10, 10, 'I', 2) }.to raise_error(TypeError)
  end
end

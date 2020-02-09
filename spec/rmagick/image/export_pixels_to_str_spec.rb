RSpec.describe Magick::Image, '#export_pixels_to_str' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      res = @img.export_pixels_to_str
      expect(res).to be_instance_of(String)
      expect(res.length).to eq(@img.columns * @img.rows * 'RGB'.length)
    end.not_to raise_error
    expect { @img.export_pixels_to_str(0) }.not_to raise_error
    expect { @img.export_pixels_to_str(0, 0) }.not_to raise_error
    expect { @img.export_pixels_to_str(0, 0, 10) }.not_to raise_error
    expect { @img.export_pixels_to_str(0, 0, 10, 10) }.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'RGBA')
      expect(res.length).to eq(10 * 10 * 'RGBA'.length)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I')
      expect(res.length).to eq(10 * 10 * 'I'.length)
    end.not_to raise_error

    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::CharPixel)
      expect(res.length).to eq(10 * 10 * 1)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::ShortPixel)
      expect(res.length).to eq(10 * 10 * 2)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::LongPixel)
      expect(res.length).to eq(10 * 10 * [1].pack('L!').length)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::FloatPixel)
      expect(res.length).to eq(10 * 10 * 4)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::DoublePixel)
      expect(res.length).to eq(10 * 10 * 8)
    end.not_to raise_error
    expect { @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel) }.not_to raise_error

    # too many arguments
    expect { @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel, 1) }.to raise_error(ArgumentError)
    # last arg s/b StorageType
    expect { @img.export_pixels_to_str(0, 0, 10, 10, 'I', 2) }.to raise_error(TypeError)
  end
end

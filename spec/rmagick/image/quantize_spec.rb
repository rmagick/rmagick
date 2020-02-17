RSpec.describe Magick::Image, '#quantize' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.quantize
    expect(result).to be_instance_of(described_class)

    Magick::ColorspaceType.values do |cs|
      expect { image.quantize(256, cs) }.not_to raise_error
    end
    expect { image.quantize(256, Magick::RGBColorspace, false) }.not_to raise_error
    expect { image.quantize(256, Magick::RGBColorspace, true) }.not_to raise_error
    expect { image.quantize(256, Magick::RGBColorspace, Magick::NoDitherMethod) }.not_to raise_error
    expect { image.quantize(256, Magick::RGBColorspace, Magick::RiemersmaDitherMethod) }.not_to raise_error
    expect { image.quantize(256, Magick::RGBColorspace, Magick::FloydSteinbergDitherMethod) }.not_to raise_error
    expect { image.quantize(256, Magick::RGBColorspace, true, 2) }.not_to raise_error
    expect { image.quantize(256, Magick::RGBColorspace, true, 2, true) }.not_to raise_error
    expect { image.quantize('x') }.to raise_error(TypeError)
    expect { image.quantize(16, 2) }.to raise_error(TypeError)
    expect { image.quantize(16, Magick::RGBColorspace, false, 'x') }.to raise_error(TypeError)
    expect { image.quantize(256, Magick::RGBColorspace, true, 2, true, true) }.to raise_error(ArgumentError)
  end
end

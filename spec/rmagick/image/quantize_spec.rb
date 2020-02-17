RSpec.describe Magick::Image, '#quantize' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.quantize
    expect(res).to be_instance_of(described_class)

    Magick::ColorspaceType.values do |cs|
      expect { img.quantize(256, cs) }.not_to raise_error
    end
    expect { img.quantize(256, Magick::RGBColorspace, false) }.not_to raise_error
    expect { img.quantize(256, Magick::RGBColorspace, true) }.not_to raise_error
    expect { img.quantize(256, Magick::RGBColorspace, Magick::NoDitherMethod) }.not_to raise_error
    expect { img.quantize(256, Magick::RGBColorspace, Magick::RiemersmaDitherMethod) }.not_to raise_error
    expect { img.quantize(256, Magick::RGBColorspace, Magick::FloydSteinbergDitherMethod) }.not_to raise_error
    expect { img.quantize(256, Magick::RGBColorspace, true, 2) }.not_to raise_error
    expect { img.quantize(256, Magick::RGBColorspace, true, 2, true) }.not_to raise_error
    expect { img.quantize('x') }.to raise_error(TypeError)
    expect { img.quantize(16, 2) }.to raise_error(TypeError)
    expect { img.quantize(16, Magick::RGBColorspace, false, 'x') }.to raise_error(TypeError)
    expect { img.quantize(256, Magick::RGBColorspace, true, 2, true, true) }.to raise_error(ArgumentError)
  end
end

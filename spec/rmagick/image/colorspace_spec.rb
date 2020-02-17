RSpec.describe Magick::Image, '#colorspace' do
  it 'works' do
    image1 = described_class.new(100, 100)

    expect { image1.colorspace }.not_to raise_error
    expect(image1.colorspace).to be_instance_of(Magick::ColorspaceType)
    expect(image1.colorspace).to eq(Magick::SRGBColorspace)
    image2 = image1.copy

    Magick::ColorspaceType.values do |colorspace|
      expect { image2.colorspace = colorspace }.not_to raise_error
    end
    expect { image1.colorspace = 2 }.to raise_error(TypeError)
    Magick::ColorspaceType.values.each do |cs|
      expect { image2.colorspace = cs }.not_to raise_error
    end
  end
end

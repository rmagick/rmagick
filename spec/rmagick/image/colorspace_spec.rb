RSpec.describe Magick::Image, '#colorspace' do
  it 'works' do
    img1 = described_class.new(100, 100)

    expect { img1.colorspace }.not_to raise_error
    expect(img1.colorspace).to be_instance_of(Magick::ColorspaceType)
    expect(img1.colorspace).to eq(Magick::SRGBColorspace)
    img2 = img1.copy

    Magick::ColorspaceType.values do |colorspace|
      expect { img2.colorspace = colorspace }.not_to raise_error
    end
    expect { img1.colorspace = 2 }.to raise_error(TypeError)
    Magick::ColorspaceType.values.each do |cs|
      expect { img2.colorspace = cs }.not_to raise_error
    end
  end
end

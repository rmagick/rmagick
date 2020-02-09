RSpec.describe Magick::Image, '#colorspace' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.colorspace }.not_to raise_error
    expect(@img.colorspace).to be_instance_of(Magick::ColorspaceType)
    expect(@img.colorspace).to eq(Magick::SRGBColorspace)
    img2 = @img.copy

    Magick::ColorspaceType.values do |colorspace|
      expect { img2.colorspace = colorspace }.not_to raise_error
    end
    expect { @img.colorspace = 2 }.to raise_error(TypeError)
    Magick::ColorspaceType.values.each do |cs|
      expect { img2.colorspace = cs }.not_to raise_error
    end
  end
end

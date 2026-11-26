# frozen_string_literal: true

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

  # The failed change leaves the image broken, and a copy of it then fails to
  # sync its pixel cache without setting an exception.
  it 'raises an error instead of aborting after it runs out of resources', if: Gem::Version.new(Magick::IMAGEMAGICK_VERSION) >= Gem::Version.new('7.0.0') do
    image = described_class.new(20, 20)
    source = described_class.new(20, 20)

    expect { without_resources { image.colorspace = Magick::CMYKColorspace } }.to raise_error(Magick::ImageMagickError)
    expect { image.composite(source, 0, 0, Magick::OverCompositeOp) }.to raise_error(Magick::ImageMagickError, /no explanation/)
  end
end

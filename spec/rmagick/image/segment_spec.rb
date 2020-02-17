RSpec.describe Magick::Image, '#segment' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.segment
    expect(res).to be_instance_of(described_class)

    # Don't test colorspaces that require PsuedoColor images
    (Magick::ColorspaceType.values - [
      Magick::OHTAColorspace,
      Magick::LabColorspace,
      Magick::XYZColorspace,
      Magick::YCbCrColorspace,
      Magick::YCCColorspace,
      Magick::YIQColorspace,
      Magick::YPbPrColorspace,
      Magick::YUVColorspace,
      Magick::Rec601YCbCrColorspace,
      Magick::Rec709YCbCrColorspace,
      Magick::LogColorspace
    ]).each do |cs|
      expect { img.segment(cs) }.not_to raise_error
    end

    expect { img.segment(Magick::RGBColorspace, 2.0) }.not_to raise_error
    expect { img.segment(Magick::RGBColorspace, 2.0, 2.0) }.not_to raise_error
    expect { img.segment(Magick::RGBColorspace, 2.0, 2.0, false) }.not_to raise_error

    expect { img.segment(Magick::RGBColorspace, 2.0, 2.0, false, 2) }.to raise_error(ArgumentError)
    expect { img.segment(2) }.to raise_error(TypeError)
    expect { img.segment(Magick::RGBColorspace, 'x') }.to raise_error(TypeError)
    expect { img.segment(Magick::RGBColorspace, 2.0, 'x') }.to raise_error(TypeError)
  end
end

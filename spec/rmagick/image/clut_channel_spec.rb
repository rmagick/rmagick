RSpec.describe Magick::Image, "#clut_channel" do
  it "works" do
    img = described_class.new(20, 20) { self.colorspace = Magick::GRAYColorspace }
    clut = described_class.new(20, 1) { self.background_color = 'red' }

    res = img.clut_channel(clut)
    expect(res).to be(img)

    expect { img.clut_channel(clut, Magick::RedChannel) }.not_to raise_error
    expect { img.clut_channel(clut, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img.clut_channel }.to raise_error(ArgumentError)
    expect { img.clut_channel(clut, 1, Magick::RedChannel) }.to raise_error(ArgumentError)
  end
end

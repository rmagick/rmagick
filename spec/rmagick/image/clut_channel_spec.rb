RSpec.describe Magick::Image, "#clut_channel" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    img = Magick::Image.new(20, 20) { self.colorspace = Magick::GRAYColorspace }
    clut = Magick::Image.new(20, 1) { self.background_color = 'red' }
    res = nil
    expect { res = img.clut_channel(clut) }.not_to raise_error
    expect(res).to be(img)
    expect { img.clut_channel(clut, Magick::RedChannel) }.not_to raise_error
    expect { img.clut_channel(clut, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img.clut_channel }.to raise_error(ArgumentError)
    expect { img.clut_channel(clut, 1, Magick::RedChannel) }.to raise_error(ArgumentError)
  end
end

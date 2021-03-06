RSpec.describe Magick::Image, "#clut_channel" do
  it "works" do
    image = described_class.new(20, 20) { |options| options.colorspace = Magick::GRAYColorspace }
    clut = described_class.new(20, 1) { |options| options.background_color = 'red' }

    result = image.clut_channel(clut)
    expect(result).to be(image)

    expect { image.clut_channel(clut, Magick::RedChannel) }.not_to raise_error
    expect { image.clut_channel(clut, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.clut_channel }.to raise_error(ArgumentError)
    expect { image.clut_channel(clut, 1, Magick::RedChannel) }.to raise_error(ArgumentError)
  end
end

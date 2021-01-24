RSpec.describe Magick::Image, "#clut_channel" do
  it "works" do
    image = described_class.new(20, 20) { self.colorspace = Magick::GRAYColorspace }
    clut = described_class.new(20, 1) { self.background_color = 'red' }

    result = image.clut_channel(clut)
    expect(result).to be(image)

    expect { image.clut_channel(clut, Magick::RedChannel) }.not_to raise_error
    expect { image.clut_channel(clut, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.clut_channel }.to raise_error(ArgumentError)
    expect { image.clut_channel(clut, 1, Magick::RedChannel) }.to raise_error(ArgumentError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20) { self.colorspace = Magick::GRAYColorspace }

    image_list = Magick::ImageList.new
    image_list.new_image(20, 1)

    result = image.clut_channel(image_list)
    expect(result).to be(image)
  end
end

RSpec.describe Magick::Image, "#auto_gamma_channel" do
  it "works" do
    image = described_class.new(20, 20)

    res = image.auto_gamma_channel
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.auto_gamma_channel Magick::RedChannel }.not_to raise_error
    expect { image.auto_gamma_channel Magick::RedChannel, Magick::BlueChannel }.not_to raise_error
    expect { image.auto_gamma_channel(1) }.to raise_error(TypeError)
  end
end

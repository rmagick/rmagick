RSpec.describe Magick::Image, "#add_noise" do
  it "works" do
    image = described_class.new(20, 20)

    Magick::NoiseType.values do |noise|
      expect { image.add_noise(noise) }.not_to raise_error
    end
    expect { image.add_noise(0) }.to raise_error(TypeError)
  end
end

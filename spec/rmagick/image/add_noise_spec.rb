RSpec.describe Magick::Image, "#add_noise" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    Magick::NoiseType.values do |noise|
      expect { @img.add_noise(noise) }.not_to raise_error
    end
    expect { @img.add_noise(0) }.to raise_error(TypeError)
  end
end

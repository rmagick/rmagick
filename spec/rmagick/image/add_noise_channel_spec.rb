RSpec.describe Magick::Image, "#add_noise_channel" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    expect { @img.add_noise_channel(Magick::UniformNoise) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::UniformNoise, Magick::RedChannel) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::GaussianNoise, Magick::BlueChannel) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::ImpulseNoise, Magick::GreenChannel) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::LaplacianNoise, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::PoissonNoise, Magick::RedChannel, Magick::GreenChannel, Magick::BlueChannel) }.not_to raise_error

    # Not a NoiseType
    expect { @img.add_noise_channel(1) }.to raise_error(TypeError)
    # Not a ChannelType
    expect { @img.add_noise_channel(Magick::UniformNoise, Magick::RedChannel, 1) }.to raise_error(TypeError)
    # Too few arguments
    expect { @img.add_noise_channel }.to raise_error(ArgumentError)
  end
end

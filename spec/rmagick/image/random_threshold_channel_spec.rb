# frozen_string_literal: true

RSpec.describe Magick::Image, '#random_threshold_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.random_threshold_channel('20%')
    expect(result).to be_instance_of(described_class)

    threshold = Magick::Geometry.new(20)
    expect { image.random_threshold_channel(threshold) }.not_to raise_error
    expect { image.random_threshold_channel(threshold, Magick::RedChannel) }.not_to raise_error
    expect { image.random_threshold_channel(threshold, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image.random_threshold_channel }.to raise_error(ArgumentError)
    expect { image.random_threshold_channel('20%', 2) }.to raise_error(TypeError)
    expect { image.random_threshold_channel('invalid', Magick::AllChannels) }.to raise_error(Magick::ImageMagickError)
  end

  it 'reads a percentage as a fraction of QuantumRange' do
    image = described_class.read('gradient:') { |info| info.size = '4x256' }.first

    result = image.random_threshold_channel('25%')

    expect(result.channel_mean(Magick::RedChannel).first / Magick::QuantumRange).to be_within(0.02).of(0.75)
  end

  it 'performs an ordered dither for 2x2, 3x3 and 4x4' do
    image = described_class.read('gradient:') { |info| info.size = '16x64' }.first

    %w[2x2 3x3 4x4].each do |map|
      expect(image.random_threshold_channel(map).signature).to eq(image.ordered_dither(map).signature)
    end
  end
end

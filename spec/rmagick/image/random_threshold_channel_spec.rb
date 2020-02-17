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
  end
end

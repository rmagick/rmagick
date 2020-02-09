RSpec.describe Magick::Image, '#levelize_channel' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    res = nil
    expect do
      res = @img.levelize_channel(0, Magick::QuantumRange)
    end.not_to raise_error
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(@img)

    expect { @img.levelize_channel(0) }.not_to raise_error
    expect { @img.levelize_channel(0, Magick::QuantumRange) }.not_to raise_error
    expect { @img.levelize_channel(0, Magick::QuantumRange, 0.5) }.not_to raise_error
    expect { @img.levelize_channel(0, Magick::QuantumRange, 0.5, Magick::RedChannel) }.not_to raise_error
    expect { @img.levelize_channel(0, Magick::QuantumRange, 0.5, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error

    expect { @img.levelize_channel(0, Magick::QuantumRange, 0.5, 1, Magick::RedChannel) }.to raise_error(TypeError)
    expect { @img.levelize_channel }.to raise_error(ArgumentError)
  end
end

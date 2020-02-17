RSpec.describe Magick::Image, '#level_channel' do
  it 'works' do
    img = described_class.new(20, 20)

    expect { img.level_channel }.to raise_error(ArgumentError)

    res = img.level_channel(Magick::RedChannel)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)

    expect { img.level_channel(Magick::RedChannel, 0.0) }.not_to raise_error
    expect { img.level_channel(Magick::RedChannel, 0.0, 1.0) }.not_to raise_error
    expect { img.level_channel(Magick::RedChannel, 0.0, 1.0, Magick::QuantumRange) }.not_to raise_error

    expect { img.level_channel(Magick::RedChannel, 0.0, 1.0, Magick::QuantumRange, 2) }.to raise_error(ArgumentError)
    expect { img.level_channel(2) }.to raise_error(TypeError)
    expect { img.level_channel(Magick::RedChannel, 'x') }.to raise_error(TypeError)
    expect { img.level_channel(Magick::RedChannel, 0.0, 'x') }.to raise_error(TypeError)
    expect { img.level_channel(Magick::RedChannel, 0.0, 1.0, 'x') }.to raise_error(TypeError)
  end
end

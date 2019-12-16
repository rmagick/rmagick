RSpec.describe Magick::Image, '#level_channel' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect { @img.level_channel }.to raise_error(ArgumentError)
    expect do
      res = @img.level_channel(Magick::RedChannel)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    expect { @img.level_channel(Magick::RedChannel, 0.0) }.not_to raise_error
    expect { @img.level_channel(Magick::RedChannel, 0.0, 1.0) }.not_to raise_error
    expect { @img.level_channel(Magick::RedChannel, 0.0, 1.0, Magick::QuantumRange) }.not_to raise_error

    expect { @img.level_channel(Magick::RedChannel, 0.0, 1.0, Magick::QuantumRange, 2) }.to raise_error(ArgumentError)
    expect { @img.level_channel(2) }.to raise_error(TypeError)
    expect { @img.level_channel(Magick::RedChannel, 'x') }.to raise_error(TypeError)
    expect { @img.level_channel(Magick::RedChannel, 0.0, 'x') }.to raise_error(TypeError)
    expect { @img.level_channel(Magick::RedChannel, 0.0, 1.0, 'x') }.to raise_error(TypeError)
  end
end

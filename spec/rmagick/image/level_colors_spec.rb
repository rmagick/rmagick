RSpec.describe Magick::Image, '#level_colors' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.level_colors
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.level_colors('black') }.not_to raise_error
    expect { image.level_colors('black', Magick::Pixel.new(0, 0, 0)) }.not_to raise_error
    expect { image.level_colors(Magick::Pixel.new(0, 0, 0), Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange, Magick::QuantumRange)) }.not_to raise_error
    expect { image.level_colors('black', 'white') }.not_to raise_error
    expect { image.level_colors('black', 'white', false) }.not_to raise_error

    expect { image.level_colors('black', 'white', false, 1) }.to raise_error(TypeError)
    expect { image.level_colors([]) }.to raise_error(TypeError)
    expect { image.level_colors('xxx') }.to raise_error(ArgumentError)
  end
end

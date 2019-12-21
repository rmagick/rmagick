RSpec.describe Magick::Image, '#level_colors' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    res = nil
    expect do
      res = @img.level_colors
    end.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(@img)

    expect { @img.level_colors('black') }.not_to raise_error
    expect { @img.level_colors('black', Magick::Pixel.new(0, 0, 0)) }.not_to raise_error
    expect { @img.level_colors(Magick::Pixel.new(0, 0, 0), Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange, Magick::QuantumRange)) }.not_to raise_error
    expect { @img.level_colors('black', 'white') }.not_to raise_error
    expect { @img.level_colors('black', 'white', false) }.not_to raise_error

    expect { @img.level_colors('black', 'white', false, 1) }.to raise_error(TypeError)
    expect { @img.level_colors([]) }.to raise_error(TypeError)
    expect { @img.level_colors('xxx') }.to raise_error(ArgumentError)
  end
end

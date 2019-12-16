RSpec.describe Magick::Image, '#fx' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect { @img.fx('1/2') }.not_to raise_error
    expect { @img.fx('1/2', Magick::BlueChannel) }.not_to raise_error
    expect { @img.fx('1/2', Magick::BlueChannel, Magick::RedChannel) }.not_to raise_error
    expect { @img.fx }.to raise_error(ArgumentError)
    expect { @img.fx(Magick::BlueChannel) }.to raise_error(ArgumentError)
    expect { @img.fx(1) }.to raise_error(TypeError)
    expect { @img.fx('1/2', 1) }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#fx' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.fx('1/2') }.not_to raise_error
    expect { image.fx('1/2', Magick::BlueChannel) }.not_to raise_error
    expect { image.fx('1/2', Magick::BlueChannel, Magick::RedChannel) }.not_to raise_error
    expect { image.fx }.to raise_error(ArgumentError)
    expect { image.fx(Magick::BlueChannel) }.to raise_error(ArgumentError)
    expect { image.fx(1) }.to raise_error(TypeError)
    expect { image.fx('1/2', 1) }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#convolve_channel' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect { @img.convolve_channel }.to raise_error(ArgumentError)
    expect { @img.convolve_channel(0) }.to raise_error(ArgumentError)
    expect { @img.convolve_channel(-1) }.to raise_error(ArgumentError)
    expect { @img.convolve_channel(3) }.to raise_error(ArgumentError)
    kernel = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    order = 3
    expect do
      res = @img.convolve_channel(order, kernel, Magick::RedChannel)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    expect { @img.convolve_channel(order, kernel, Magick::RedChannel, Magick:: BlueChannel) }.not_to raise_error
    expect { @img.convolve_channel(order, kernel, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end

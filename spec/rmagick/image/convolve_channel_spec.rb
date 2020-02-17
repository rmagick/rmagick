RSpec.describe Magick::Image, '#convolve_channel' do
  it 'works' do
    img = described_class.new(20, 20)

    expect { img.convolve_channel }.to raise_error(ArgumentError)
    expect { img.convolve_channel(0) }.to raise_error(ArgumentError)
    expect { img.convolve_channel(-1) }.to raise_error(ArgumentError)
    expect { img.convolve_channel(3) }.to raise_error(ArgumentError)
    kernel = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    order = 3

    res = img.convolve_channel(order, kernel, Magick::RedChannel)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)

    expect { img.convolve_channel(order, kernel, Magick::RedChannel, Magick:: BlueChannel) }.not_to raise_error
    expect { img.convolve_channel(order, kernel, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#channel_entropy' do
  pixels = [[45, 9, 156], [45, 98, 156], [45, 74, 156], [45, 196, 156]]

  it 'returns a channel entropy', unsupported_before('6.9.0') do
    image = build_image(pixels: pixels)

    result = image.channel_entropy

    expect(result).to eq([0.3333333333333333])
  end

  it 'returns 0.0 when all pixels are the same', unsupported_before('6.9.0') do
    image = build_image(pixels: pixels)

    result = image.channel_entropy(Magick::RedChannel)

    expect(result).to eq([0.0])
  end

  it 'returns 1.0 when all pixels are different', unsupported_before('6.9.0') do
    image = build_image(pixels: pixels)

    result = image.channel_entropy(Magick::GreenChannel)

    expect(result).to eq([1.0])
  end

  it 'returns the entropy of multiple given channels', unsupported_before('6.9.0') do
    image = build_image(pixels: pixels)

    result = image.channel_entropy(Magick::GreenChannel, Magick::BlueChannel)

    expect(result).to eq([0.5])
  end

  it 'raises an error on earlier versions', supported_before('6.9.0') do
    image = build_image

    expect { image.channel_entropy }.to raise_error(NotImplementedError)
  end
end

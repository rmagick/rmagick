# frozen_string_literal: true

RSpec.describe Magick::TextureFill, '#fill' do
  it 'works' do
    granite = Magick::Image.read('granite:').first
    texture = described_class.new(granite)

    image = Magick::Image.new(10, 10)
    obj = texture.fill(image)
    expect(obj).to eq(texture)

    imgl = Magick::ImageList.new
    imgl.new_image(10, 10)

    obj = texture.fill(imgl)
    expect(obj).to eq(texture)
  end

  it 'raises RuntimeError when the fill is not initialized' do
    expect { described_class.allocate.fill(Magick::Image.new(2, 2)) }.to raise_error(RuntimeError, /has not been initialized/)
  end
end

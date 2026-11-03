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

  it 'raises FrozenError for a frozen image and leaves its pixels as they are' do
    texture = described_class.new(Magick::Image.new(2, 2) { |options| options.background_color = 'red' })
    image = Magick::Image.new(4, 4).freeze
    pixels = image.export_pixels

    image_list = Magick::ImageList.new
    image_list << image

    expect { texture.fill(image) }.to raise_error(FrozenError)
    expect { texture.fill(image_list) }.to raise_error(FrozenError)
    expect(image.export_pixels).to eq(pixels)
  end
end

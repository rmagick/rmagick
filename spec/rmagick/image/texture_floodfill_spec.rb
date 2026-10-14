# frozen_string_literal: true

RSpec.describe Magick::Image, '#texture_floodfill' do
  it 'works' do
    image = described_class.new(20, 20)
    texture = described_class.read('granite:').first

    result = image.texture_floodfill(image.columns / 2, image.rows / 2, texture)
    expect(result).to be_instance_of(described_class)

    expect { image.texture_floodfill(image.columns / 2, image.rows / 2, 'x') }.to raise_error(NoMethodError)
    texture.destroy!
    expect { image.texture_floodfill(image.columns / 2, image.rows / 2, texture) }.to raise_error(Magick::DestroyedImageError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.texture_floodfill(image.columns / 2, image.rows / 2, image_list) }.not_to raise_error
  end

  it 'fills only the pixels with the black of a CMYK image' do
    image = described_class.new(2, 1)
    image.colorspace = Magick::CMYKColorspace
    black = Magick::Pixel.new(0, 0, 0)
    black.black = Magick::QuantumRange
    image.pixel_color(1, 0, black)
    texture = described_class.new(1, 1) { |options| options.background_color = 'red' }

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    pixels = image.texture_floodfill(1, 0, texture).get_pixels(0, 0, 2, 1)

    expect(pixels[1].black).to eq(0)
    expect(pixels[0]).to eq(image.pixel_color(0, 0))
  end

  it 'converts a color name to CMYK for a CMYK image' do
    image = described_class.new(2, 1)
    image.pixel_color(1, 0, 'black')
    image.colorspace = Magick::CMYKColorspace

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    texture = described_class.new(1, 1) { |options| options.background_color = 'red' }

    pixels = image.texture_flood_fill('black', texture, 1, 0, Magick::FloodfillMethod).get_pixels(0, 0, 2, 1)

    expect(pixels[1].black).to eq(0)
    expect(pixels[0]).to eq(image.pixel_color(0, 0))
  end
end

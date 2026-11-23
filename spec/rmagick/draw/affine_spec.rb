# frozen_string_literal: true

RSpec.describe Magick::Draw, '#affine' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.affine(10.5, 12, 15, 20, 22, 25)
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.affine('x', 12, 15, 20, 22, 25) }.to raise_error(ArgumentError)
    expect { draw.affine(10, 'x', 15, 20, 22, 25) }.to raise_error(ArgumentError)
    expect { draw.affine(10, 12, 'x', 20, 22, 25) }.to raise_error(ArgumentError)
    expect { draw.affine(10, 12, 15, 'x', 22, 25) }.to raise_error(ArgumentError)
    expect { draw.affine(10, 12, 15, 20, 'x', 25) }.to raise_error(ArgumentError)
    expect { draw.affine(10, 12, 15, 20, 22, 'x') }.to raise_error(ArgumentError)
  end

  it 'maps a point as AffineMatrix does on any ImageMagick version' do
    image = Magick::Image.new(40, 40)
    draw = described_class.new

    draw.affine(1, 0.5, 0, 1, 0, 0)
    draw.point(20, 10)
    draw.draw(image)

    expect(image.pixel_color(20, 20)).to eq(Magick::Pixel.from_color('black'))
    expect(image.pixel_color(25, 10)).to eq(Magick::Pixel.from_color('white'))
  end
end

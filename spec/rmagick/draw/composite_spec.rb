# frozen_string_literal: true

RSpec.describe Magick::Draw, '#composite' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(10, 10)

    expect { draw.composite(0, 0, 10, 10, image) }.not_to raise_error

    Magick::CompositeOperator.values do |op|
      expect { draw.composite(0, 0, 10, 10, image, op) }.not_to raise_error
    end

    expect { draw.composite('x', 0, 10, 10, image) }.to raise_error(TypeError)
    expect { draw.composite(0, 'y', 10, 10, image) }.to raise_error(TypeError)
    expect { draw.composite(0, 0, 'w', 10, image) }.to raise_error(TypeError)
    expect { draw.composite(0, 0, 10, 'h', image) }.to raise_error(TypeError)
    expect { draw.composite(0, 0, 10, 10, image, Magick::CenterAlign) }.to raise_error(TypeError)
    expect { draw.composite(0, 0, 10, 10, 'image') }.to raise_error(NoMethodError)
    expect { draw.composite(0, 0, 10, 10) }.to raise_error(ArgumentError)
    expect { draw.composite(0, 0, 10, 10, image, Magick::ModulusAddCompositeOp, 'x') }.to raise_error(ArgumentError)
  end

  it 'accepts an ImageList argument' do
    draw = described_class.new

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { draw.composite(0, 0, 10, 10, image_list) }.not_to raise_error
    expect { draw.composite(0, 0, 10, 10, image_list, Magick::BlendCompositeOp) }.not_to raise_error
  end

  it 'draws each composited image' do
    draw = described_class.new
    draw.composite(0, 0, 2, 2, Magick::Image.new(2, 2) { |options| options.background_color = 'red' })
    draw.composite(2, 0, 2, 2, Magick::Image.new(2, 2) { |options| options.background_color = 'blue' })
    image = Magick::Image.new(4, 2)
    draw.draw(image)

    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
    expect(image.pixel_color(2, 0)).to eq(Magick::Pixel.from_color('blue'))
  end

  it 'raises an error when converting an argument destroys the image' do
    draw = described_class.new
    image = Magick::Image.new(10, 10)
    x = Struct.new(:image) do
      def to_f
        image.destroy! && 0.0
      end
    end.new(image)

    expect { draw.composite(x, 0, 10, 10, image) }.to raise_error(Magick::DestroyedImageError)
  end
end

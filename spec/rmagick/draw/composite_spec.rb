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
end

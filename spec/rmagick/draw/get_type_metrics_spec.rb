# frozen_string_literal: true

RSpec.describe Magick::Draw, '#get_type_metrics' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(10, 10)

    expect { draw.get_type_metrics('ABCDEF') }.not_to raise_error
    expect { draw.get_type_metrics(image, 'ABCDEF') }.not_to raise_error

    expect { draw.get_type_metrics }.to raise_error(ArgumentError)
    expect { draw.get_type_metrics(image, 'ABCDEF', 20) }.to raise_error(ArgumentError)
    expect { draw.get_type_metrics(image, '') }.to raise_error(ArgumentError)
    expect { draw.get_type_metrics('x', 'ABCDEF') }.to raise_error(NoMethodError)
  end

  it 'accepts an ImageList argument' do
    draw = described_class.new

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { draw.get_type_metrics(image_list, 'ABCDEF') }.not_to raise_error
  end

  # The text is no longer run through InterpretImageProperties(), so an escape in
  # it is measured rather than replaced -- including a malformed one, which used
  # to make the interpretation fail.
  it 'measures a percent escape as text' do
    draw = described_class.new
    small = Magick::Image.new(1, 1)
    large = Magick::Image.new(1234, 1)

    %i[get_type_metrics get_multiline_type_metrics].each do |method_name|
      expect { draw.public_send(method_name, small, '%[fx:(]') }.not_to raise_error
      expect(draw.public_send(method_name, small, '%[width]').width)
        .to eq(draw.public_send(method_name, large, '%[width]').width)
    end
  end
end

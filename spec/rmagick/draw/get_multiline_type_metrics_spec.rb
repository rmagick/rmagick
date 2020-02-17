RSpec.describe Magick::Draw, '#get_multiline_type_metrics' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(10, 10)

    expect { draw.get_multiline_type_metrics('ABCDEF') }.not_to raise_error
    expect { draw.get_multiline_type_metrics(image, 'ABCDEF') }.not_to raise_error

    expect { draw.get_multiline_type_metrics }.to raise_error(ArgumentError)
    expect { draw.get_multiline_type_metrics(image, 'ABCDEF', 20) }.to raise_error(ArgumentError)
    expect { draw.get_multiline_type_metrics(image, '') }.to raise_error(ArgumentError)
  end
end

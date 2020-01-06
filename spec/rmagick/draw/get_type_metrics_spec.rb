RSpec.describe Magick::Draw, '#get_type_metrics' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(10, 10)

    expect { draw.get_type_metrics('ABCDEF') }.not_to raise_error
    expect { draw.get_type_metrics(img, 'ABCDEF') }.not_to raise_error

    expect { draw.get_type_metrics }.to raise_error(ArgumentError)
    expect { draw.get_type_metrics(img, 'ABCDEF', 20) }.to raise_error(ArgumentError)
    expect { draw.get_type_metrics(img, '') }.to raise_error(ArgumentError)
    expect { draw.get_type_metrics('x', 'ABCDEF') }.to raise_error(NoMethodError)
  end
end

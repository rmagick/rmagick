RSpec.describe Magick::Image, '#sketch' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.sketch }.not_to raise_error
    expect { image.sketch(0) }.not_to raise_error
    expect { image.sketch(0, 1) }.not_to raise_error
    expect { image.sketch(0, 1, 0) }.not_to raise_error
    expect { image.sketch(0, 1, 0, 1) }.to raise_error(ArgumentError)
    expect { image.sketch('x') }.to raise_error(TypeError)
    expect { image.sketch(0, 'x') }.to raise_error(TypeError)
    expect { image.sketch(0, 1, 'x') }.to raise_error(TypeError)
  end
end

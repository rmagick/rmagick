RSpec.describe Magick::Draw, '#composite' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    img = Magick::Image.new(10, 10)
    expect { @draw.composite(0, 0, 10, 10, img) }.not_to raise_error

    Magick::CompositeOperator.values do |op|
      expect { @draw.composite(0, 0, 10, 10, img, op) }.not_to raise_error
    end

    expect { @draw.composite('x', 0, 10, 10, img) }.to raise_error(TypeError)
    expect { @draw.composite(0, 'y', 10, 10, img) }.to raise_error(TypeError)
    expect { @draw.composite(0, 0, 'w', 10, img) }.to raise_error(TypeError)
    expect { @draw.composite(0, 0, 10, 'h', img) }.to raise_error(TypeError)
    expect { @draw.composite(0, 0, 10, 10, img, Magick::CenterAlign) }.to raise_error(TypeError)
    expect { @draw.composite(0, 0, 10, 10, 'image') }.to raise_error(NoMethodError)
    expect { @draw.composite(0, 0, 10, 10) }.to raise_error(ArgumentError)
    expect { @draw.composite(0, 0, 10, 10, img, Magick::ModulusAddCompositeOp, 'x') }.to raise_error(ArgumentError)
  end
end

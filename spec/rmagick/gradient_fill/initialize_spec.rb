RSpec.describe Magick::GradientFill, '#initialize' do
  it 'works' do
    expect(described_class.new(0, 0, 0, 100, '#900', '#000')).to be_instance_of(described_class)
    expect(described_class.new(0, 0, 0, 100, 'white', 'red')).to be_instance_of(described_class)

    expect { described_class.new(0, 0, 0, 100, 'foo', '#000') }.to raise_error(ArgumentError)
    expect { described_class.new(0, 0, 0, 100, '#900', 'bar') }.to raise_error(ArgumentError)
    expect { described_class.new('x1', 0, 0, 100, '#900', '#000') }.to raise_error(TypeError)
    expect { described_class.new(0, 'y1', 0, 100, '#900', '#000') }.to raise_error(TypeError)
    expect { described_class.new(0, 0, 'x2', 100, '#900', '#000') }.to raise_error(TypeError)
    expect { described_class.new(0, 0, 0, 'y2', '#900', '#000') }.to raise_error(TypeError)
  end
end

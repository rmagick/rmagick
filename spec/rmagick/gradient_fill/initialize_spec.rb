RSpec.describe Magick::GradientFill, '#initialize' do
  it 'works' do
    expect(Magick::GradientFill.new(0, 0, 0, 100, '#900', '#000')).to be_instance_of(Magick::GradientFill)
    expect(Magick::GradientFill.new(0, 0, 0, 100, 'white', 'red')).to be_instance_of(Magick::GradientFill)

    expect { Magick::GradientFill.new(0, 0, 0, 100, 'foo', '#000') }.to raise_error(ArgumentError)
    expect { Magick::GradientFill.new(0, 0, 0, 100, '#900', 'bar') }.to raise_error(ArgumentError)
    expect { Magick::GradientFill.new('x1', 0, 0, 100, '#900', '#000') }.to raise_error(TypeError)
    expect { Magick::GradientFill.new(0, 'y1', 0, 100, '#900', '#000') }.to raise_error(TypeError)
    expect { Magick::GradientFill.new(0, 0, 'x2', 100, '#900', '#000') }.to raise_error(TypeError)
    expect { Magick::GradientFill.new(0, 0, 0, 'y2', '#900', '#000') }.to raise_error(TypeError)
  end
end

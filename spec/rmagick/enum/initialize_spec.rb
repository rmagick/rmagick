RSpec.describe Magick::Enum, '#initialize' do
  it 'works' do
    expect { Magick::Enum.new(:foo, 42) }.not_to raise_error
    expect { Magick::Enum.new('foo', 42) }.not_to raise_error

    expect { Magick::Enum.new(Object.new, 42) }.to raise_error(TypeError)
    expect { Magick::Enum.new(:foo, 'x') }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Enum, '#initialize' do
  it 'works' do
    expect { described_class.new(:foo, 42) }.not_to raise_error
    expect { described_class.new('foo', 42) }.not_to raise_error

    expect { described_class.new(Object.new, 42) }.to raise_error(TypeError)
    expect { described_class.new(:foo, 'x') }.to raise_error(TypeError)
  end
end

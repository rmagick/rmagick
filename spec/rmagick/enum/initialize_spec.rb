# frozen_string_literal: true

RSpec.describe Magick::Enum, '#initialize' do
  it 'works' do
    expect { described_class.new(:foo, 42) }.not_to raise_error
    expect { described_class.new('foo', 42) }.not_to raise_error

    expect { described_class.new(Object.new, 42) }.to raise_error(TypeError)
    expect { described_class.new(:foo, 'x') }.to raise_error(TypeError)
  end

  it 'raises FrozenError when called again' do
    enum = described_class.new(:foo, 42)

    expect { enum.__send__(:initialize, :bar, 1) }.to raise_error(FrozenError)
    expect(enum.to_s).to eq('foo')
    expect(enum).to eq(described_class.new(:foo, 42))
  end

  it 'can be called again after the first call fails' do
    enum = Magick::ColorspaceType.allocate

    expect { enum.__send__(:initialize, :foo, 'x') }.to raise_error(TypeError)
    expect { enum.__send__(:initialize, :foo, 42) }.not_to raise_error
    expect(enum.inspect).to eq('foo=42')
  end

  it 'does not change a shared constant when called again' do
    values = Magick::ColorspaceType.values

    expect { Magick::RGBColorspace.__send__(:initialize, :Hacked, 4242) }
      .to raise_error(FrozenError, /\Acan't modify frozen Magick::ColorspaceType: RGBColorspace=\d+\z/)
    expect(Magick::RGBColorspace.to_s).to eq('RGBColorspace')
    expect(Magick::ColorspaceType.values).to eq(values)
  end
end

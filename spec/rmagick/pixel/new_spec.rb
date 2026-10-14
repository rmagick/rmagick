# frozen_string_literal: true

RSpec.describe Magick::Pixel, '.new' do
  it 'is opaque by default' do
    expect(described_class.new(1, 2, 3).alpha).to eq(Magick::QuantumRange)
  end

  it 'treats the fourth argument as opacity' do
    expect(described_class.new(0, 0, 0, 0).alpha).to eq(Magick::QuantumRange)
    expect(described_class.new(0, 0, 0, Magick::QuantumRange).alpha).to eq(0)
    expect(described_class.new(1, 2, 3, 100).alpha).to eq(Magick::QuantumRange - 100)
  end

  it 'ignores a nil opacity' do
    expect(described_class.new(0, 0, 0, nil).alpha).to eq(Magick::QuantumRange)
  end

  it 'does not initialize a frozen pixel again' do
    pixel = described_class.new(1, 2, 3).freeze

    expect { pixel.__send__(:initialize, 4, 5, 6) }.to raise_error(FrozenError)
    expect(pixel.red).to eq(1)
  end

  it 'clamps an out-of-range value unless ImageMagick uses HDRI' do
    pixel = described_class.new(Magick::QuantumRange + 1, -1, 0)

    if Magick::Magick_features.include?('HDRI')
      expect(pixel.red).to eq(Magick::QuantumRange + 1)
    else
      expect(pixel.red).to eq(Magick::QuantumRange)
      expect(pixel.green).to eq(0)
    end
  end

  it 'accepts a value out of the range of int with HDRI' do
    if Magick::Magick_features.include?('HDRI')
      expect(described_class.new(10_000_000_000, 0, 0).red).to eq(10_000_000_000)
    else
      expect { described_class.new(10_000_000_000, 0, 0) }.to raise_error(RangeError)
    end
  end
end

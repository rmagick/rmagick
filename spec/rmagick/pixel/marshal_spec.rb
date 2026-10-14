# frozen_string_literal: true

RSpec.describe Magick::Pixel, '#marshal' do
  it 'works' do
    pixel = described_class.from_color('brown')

    marshal = pixel.marshal_dump

    pixel2 = described_class.new
    expect(pixel2.marshal_load(marshal)).to eq(pixel)
  end

  # Regression: a non-Hash argument used to be dereferenced as a Hash and crash
  # the process (SIGSEGV). It must raise TypeError instead.
  it 'raises TypeError for a non-Hash argument' do
    pixel = described_class.new
    expect { pixel.marshal_load(0) }.to raise_error(TypeError)
    expect { pixel.marshal_load(nil) }.to raise_error(TypeError)
    expect { pixel.marshal_load([]) }.to raise_error(TypeError)
  end

  it 'keeps a negative value of an HDRI pixel' do
    pixel = described_class.new(-65_535, 0, 0)

    expect(Marshal.load(Marshal.dump(pixel)).red).to eq(pixel.red)
  end

  it 'keeps black' do
    pixel = described_class.new(1, 2, 3)
    pixel.black = 1000

    loaded = Marshal.load(Marshal.dump(pixel))

    expect(loaded.black).to eq(1000)
    expect(loaded).to eq(pixel)
  end

  it 'loads a dump without black as 0' do
    dump = described_class.new(1, 2, 3).marshal_dump.except(:black)
    pixel = described_class.new
    pixel.black = 1000

    expect(pixel.marshal_load(dump).black).to eq(0)
    expect(pixel.marshal_load(Hash.new(123).merge!(dump)).black).to eq(0)
  end

  it 'raises FrozenError for a frozen pixel' do
    pixel = described_class.new(1, 2, 3).freeze

    expect { pixel.marshal_load(described_class.new(4, 5, 6).marshal_dump) }.to raise_error(FrozenError)
    expect(pixel.red).to eq(1)
  end
end

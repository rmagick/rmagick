# frozen_string_literal: true

RSpec.describe Magick::Image, '#marshal_load' do
  it 'works' do
    image1 = described_class.read('granite:').first
    image2 = described_class.new(10, 10)
    expect { image2.marshal_load(image1.marshal_dump) }.not_to raise_error
    expect { image2.marshal_load([1234, 5678]) }.to raise_error(TypeError)
  end

  # Regression: a non-Array argument used to be dereferenced as an Array and
  # crash the process (SIGSEGV). It must raise TypeError instead.
  it 'raises TypeError for a non-Array argument' do
    image = described_class.new(10, 10)
    expect { image.marshal_load(0) }.to raise_error(TypeError)
    expect { image.marshal_load(nil) }.to raise_error(TypeError)
    expect { image.marshal_load({}) }.to raise_error(TypeError)
  end

  it 'raises FrozenError for a frozen image and leaves it unchanged' do
    source = described_class.new(3, 3)
    source.format = 'MIFF'
    dumped = source.marshal_dump
    image = described_class.new(2, 2).freeze

    expect { image.marshal_load(dumped) }.to raise_error(FrozenError)
    expect(image.columns).to eq(2)
    expect(dumped.size).to eq(2)
  end

  it 'leaves the dumped array as it is' do
    image = described_class.new(3, 2)
    image.format = 'MIFF'
    dumped = image.marshal_dump
    copy = dumped.map(&:dup)

    described_class.new(1, 1).marshal_load(dumped)

    expect(dumped).to eq(copy)
  end

  it 'loads an image with Marshal.load and freeze: true' do
    image = described_class.new(3, 2)
    image.format = 'MIFF'

    loaded = Marshal.load(Marshal.dump(image), freeze: true)

    expect(loaded.columns).to eq(3)
  end

  it 'loads a frozen image that Ractors can share with Marshal.load and freeze: true', if: Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.3') do
    image = described_class.new(3, 2)
    image.format = 'MIFF'

    loaded = Marshal.load(Marshal.dump(image), freeze: true)

    expect(loaded).to be_frozen
    expect(Ractor.shareable?(loaded)).to be(true)
  end

  it 'keeps only the first image of a dump that reads back as several images' do
    image = described_class.new(100, 100)
    image.format = 'PSD'
    dumped = Marshal.dump(image)
    GC.start
    before = pixel_cache_size

    loaded = Marshal.load(dumped)
    loaded.destroy!

    expect(pixel_cache_size).to eq(before)
  end
end

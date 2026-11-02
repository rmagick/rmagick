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
end

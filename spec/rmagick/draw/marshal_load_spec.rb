# frozen_string_literal: true

RSpec.describe Magick::Draw, '#marshal_load' do
  it 'round-trips a dumped Draw' do
    draw = described_class.new
    draw.fill = Magick::Pixel.from_color('red')

    expect { described_class.new.marshal_load(draw.marshal_dump) }.not_to raise_error
  end

  # Regression: a non-Hash argument used to be dereferenced as a Hash and crash
  # the process (SIGSEGV). It must raise TypeError instead.
  it 'raises TypeError for a non-Hash argument' do
    draw = described_class.new
    expect { draw.marshal_load(0) }.to raise_error(TypeError)
    expect { draw.marshal_load(nil) }.to raise_error(TypeError)
    expect { draw.marshal_load([]) }.to raise_error(TypeError)
  end

  # Regression: a non-String pattern used to be reinterpreted as a String, so
  # its buffer pointer and length were read from unrelated object fields and
  # handed to BlobToImage. It must raise TypeError instead.
  it 'raises TypeError for a pattern that is not a String' do
    dumped = described_class.new.marshal_dump

    [0, :symbol, [1, 'x'], {}].each do |value|
      expect { described_class.new.marshal_load(dumped.merge(fill_pattern: value)) }.to raise_error(TypeError)
      expect { described_class.new.marshal_load(dumped.merge(stroke_pattern: value)) }.to raise_error(TypeError)
    end
  end
end

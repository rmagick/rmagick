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
end

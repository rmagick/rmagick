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
end

# frozen_string_literal: true

RSpec.describe Magick::Pixel, '#===' do
  it 'works' do
    pixel1 = described_class.from_color('brown')
    pixel2 = described_class.from_color('brown')

    expect(pixel1 === pixel2).to be(true)
    expect(pixel1 === 'red').to be(false)

    pixel2 = described_class.from_color('red')
    expect(pixel1 === pixel2).to be(false)
  end

  it 'compares the black channel' do
    pixel = described_class.new(0, 0, 0)
    other = pixel.dup
    other.black = 30_000

    expect(pixel === other).to be(false)
  end
end

# frozen_string_literal: true

RSpec.describe Magick::Pixel, '#eql?' do
  it 'works' do
    pixel = described_class.from_color('brown')

    pixel2 = pixel
    expect(pixel.eql?(pixel2)).to be(true)
    pixel2 = described_class.new
    expect(pixel.eql?(pixel2)).to be(false)
  end

  it 'returns false for an object that is not a Pixel' do
    pixel = described_class.from_color('brown')

    expect(pixel.eql?(nil)).to be(false)
    expect(pixel.eql?('brown')).to be(false)
  end
end

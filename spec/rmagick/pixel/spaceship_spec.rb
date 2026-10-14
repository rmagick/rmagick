# frozen_string_literal: true

RSpec.describe Magick::Pixel, '#<=>' do
  it 'works' do
    pixel = described_class.from_color('brown')

    pixel.red = 100
    pixel2 = pixel.dup
    expect(pixel <=> pixel2).to eq(0)

    pixel2.red -= 10
    expect(pixel <=> pixel2).to eq(1)
    pixel2.red += 20
    expect(pixel <=> pixel2).to eq(-1)

    pixel.green = 100
    pixel2 = pixel.dup
    pixel2.green -= 10
    expect(pixel <=> pixel2).to eq(1)
    pixel2.green += 20
    expect(pixel <=> pixel2).to eq(-1)

    pixel.blue = 100
    pixel2 = pixel.dup
    pixel2.blue -= 10
    expect(pixel <=> pixel2).to eq(1)
    pixel2.blue += 20
    expect(pixel <=> pixel2).to eq(-1)

    pixel.alpha = 100
    pixel2 = pixel.dup
    pixel2.alpha -= 10
    expect(pixel <=> pixel2).to eq(1)
    pixel2.alpha += 20
    expect(pixel <=> pixel2).to eq(-1)

    expect(pixel <=> Object.new).to be(nil)
  end

  it 'compares values that differ by less than 1' do
    pixel = described_class.from_color('rgb(50%,0,0)')
    other = described_class.new(Magick::QuantumRange / 2, 0, 0)

    expect(pixel <=> other).to eq(1)
    expect(other <=> pixel).to eq(-1)
  end

  it 'returns nil for a NaN value as Float#<=> does' do
    image = Magick::Image.new(1, 1) { |options| options.background_color = 'black' }
    pixel = image.fx('0/0', Magick::RedChannel).pixel_color(0, 0)
    other = described_class.new(Magick::QuantumRange, 0, 0)

    if Magick::Magick_features.include?('HDRI')
      expect(pixel <=> other).to be(nil)
      expect(pixel == other).to be(false)
      expect(pixel.eql?(other)).to be(false)
    else
      expect(pixel <=> other).to eq(-1)
    end
  end

  it 'compares the black channel' do
    pixel = described_class.new(0, 0, 0)
    other = pixel.dup
    other.black = 30_000

    expect(pixel <=> other).to eq(-1)
    expect(other <=> pixel).to eq(1)
    expect(pixel == other).to be(false)
    expect(pixel.eql?(other)).to be(false)
  end
end

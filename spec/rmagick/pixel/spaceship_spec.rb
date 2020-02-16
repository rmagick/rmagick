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
  end
end

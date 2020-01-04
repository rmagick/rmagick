RSpec.describe Magick::Pixel, '#<=>' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    @pixel.red = 100
    pixel = @pixel.dup
    expect(@pixel <=> pixel).to eq(0)

    pixel.red -= 10
    expect(@pixel <=> pixel).to eq(1)
    pixel.red += 20
    expect(@pixel <=> pixel).to eq(-1)

    @pixel.green = 100
    pixel = @pixel.dup
    pixel.green -= 10
    expect(@pixel <=> pixel).to eq(1)
    pixel.green += 20
    expect(@pixel <=> pixel).to eq(-1)

    @pixel.blue = 100
    pixel = @pixel.dup
    pixel.blue -= 10
    expect(@pixel <=> pixel).to eq(1)
    pixel.blue += 20
    expect(@pixel <=> pixel).to eq(-1)

    @pixel.alpha = 100
    pixel = @pixel.dup
    pixel.alpha -= 10
    expect(@pixel <=> pixel).to eq(1)
    pixel.alpha += 20
    expect(@pixel <=> pixel).to eq(-1)
  end
end

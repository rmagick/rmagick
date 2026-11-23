# frozen_string_literal: true

describe Magick::RVG, '#matrix' do
  it "maps a point as SVG's matrix does on any ImageMagick version" do
    rvg = described_class.new(40, 40)
    rvg.background_fill = 'white'
    rvg.matrix(1, 0.5, 0, 1, 0, 0).rect(1, 1, 20, 10).styles(fill: 'black', stroke: 'none')

    image = rvg.draw

    expect(image.pixel_color(20, 20)).to eq(Magick::Pixel.from_color('black'))
    expect(image.pixel_color(25, 10)).to eq(Magick::Pixel.from_color('white'))
  end
end

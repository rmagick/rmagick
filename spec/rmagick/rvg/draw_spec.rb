# frozen_string_literal: true

describe Magick::RVG, '#draw' do
  it 'draws a transparent background by default' do
    image = described_class.new(4, 4).draw

    expect(image.pixel_color(0, 0).alpha).to eq(Magick::TransparentAlpha)
  end

  it 'draws the background_fill with the background_fill_opacity' do
    rvg = described_class.new(4, 4)
    rvg.background_fill = 'red'
    rvg.background_fill_opacity = 0.5

    pixel = rvg.draw.pixel_color(0, 0)
    expect(pixel.red).to eq(Magick::QuantumRange)
    expect(pixel.alpha).to be_within(1).of(Magick::QuantumRange / 2)
  end
end

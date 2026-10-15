# frozen_string_literal: true

RSpec.describe Magick::Image::DrawOptions, '#initialize' do
  it 'replaces its settings when initialize is called again' do
    draw = Magick::Draw.new do |options|
      options.fill = 'red'
      options.__send__(:initialize)
    end

    draw.rectangle(0, 0, 1, 1)
    image = Magick::Image.new(2, 2)
    draw.draw(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('black'))
  end

  it 'raises FrozenError when initialize is called on frozen options' do
    options = described_class.new.freeze

    expect { options.__send__(:initialize) }.to raise_error(FrozenError)
  end
end

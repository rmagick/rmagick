# frozen_string_literal: true

RSpec.describe Magick::Draw, '#initialize' do
  it 'works' do
    yield_obj = nil

    described_class.new do |option|
      yield_obj = option
    end
    expect(yield_obj).to be_instance_of(Magick::Image::DrawOptions)
  end

  it 'replaces its settings when initialize is called again' do
    draw = described_class.new
    draw.fill = 'red'

    draw.__send__(:initialize)

    draw.rectangle(0, 0, 1, 1)
    image = Magick::Image.new(2, 2)
    draw.draw(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('black'))
  end

  it 'raises FrozenError when initialize is called on a frozen draw' do
    draw = described_class.new
    draw.fill = 'red'
    draw.rectangle(0, 0, 1, 1)
    draw.freeze

    expect { draw.__send__(:initialize) }.to raise_error(FrozenError)

    image = Magick::Image.new(2, 2)
    draw.draw(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end
end

# frozen_string_literal: true

RSpec.describe Magick::Draw, '#dup' do
  it 'works' do
    draw = described_class.new

    draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    draw.freeze
    dup = draw.dup
    expect(dup).to be_instance_of(described_class)
  end

  it 'replaces its settings when initialize_copy is called again' do
    draw = described_class.new
    draw.fill = 'red'
    draw.line(0, 0, 1, 1)
    other = described_class.new
    other.point(1, 1)

    draw.__send__(:initialize_copy, other)

    expect(draw.inspect).to eq(other.inspect)
  end

  it 'keeps its settings when initialize_copy is called with itself' do
    draw = described_class.new
    draw.fill = 'red'
    draw.rectangle(0, 0, 1, 1)

    draw.__send__(:initialize_copy, draw)

    image = Magick::Image.new(2, 2)
    draw.draw(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end

  it 'raises FrozenError when initialize_copy is called on a frozen draw' do
    draw = described_class.new
    draw.point(0, 0)
    draw.freeze
    primitives = draw.inspect

    expect { draw.__send__(:initialize_copy, described_class.new) }.to raise_error(FrozenError)
    expect(draw.inspect).to eq(primitives)
  end
end

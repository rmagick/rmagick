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

  it 'keeps the setting that a setter writes after its argument calls initialize_copy or initialize' do
    %i[initialize_copy initialize].each do |method|
      draw = described_class.new
      other = described_class.new
      color = Object.new
      color.define_singleton_method(:to_str) do
        method == :initialize ? draw.__send__(:initialize) : draw.__send__(:initialize_copy, other)
        'red'
      end

      draw.fill = color
      draw.rectangle(0, 0, 1, 1)
      image = Magick::Image.new(2, 2)
      draw.draw(image)
      expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
    end
  end

  it 'raises TypeError when initialize_copy is called with options of another class' do
    expect { described_class.allocate.__send__(:initialize_copy, Magick::Image::DrawOptions.new) }.to raise_error(TypeError)
  end

  it 'raises FrozenError when initialize_copy is called on a frozen draw' do
    draw = described_class.new
    draw.point(0, 0)
    draw.freeze
    primitives = draw.inspect

    expect { draw.__send__(:initialize_copy, described_class.new) }.to raise_error(FrozenError)
    expect(draw.inspect).to eq(primitives)
  end

  it 'keeps the composited images after the original is freed' do
    copies = Array.new(10) do
      draw = described_class.new
      draw.composite(0, 0, 2, 2, Magick::Image.new(2, 2) { |options| options.background_color = 'red' })
      draw.dup
    end
    GC.start

    copies.each do |copy|
      image = Magick::Image.new(2, 2)
      copy.draw(image)
      expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
    end
  end

  it 'deletes the composited images it held when initialize_copy is called again' do
    draw = described_class.new
    draw.composite(0, 0, 2, 2, Magick::Image.new(2, 2))
    name = draw.inspect[/mpri:\d+/]

    draw.__send__(:initialize_copy, described_class.new)

    expect(draw.inspect).to eq('(no primitives defined)')
    expect { Magick::Image.read(name) }.to raise_error(Magick::ImageMagickError)
  end

  it 'keeps the composited images when initialize_copy is called with itself' do
    draw = described_class.new
    draw.composite(0, 0, 2, 2, Magick::Image.new(2, 2) { |options| options.background_color = 'red' })

    draw.__send__(:initialize_copy, draw)

    image = Magick::Image.new(2, 2)
    draw.draw(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end
end

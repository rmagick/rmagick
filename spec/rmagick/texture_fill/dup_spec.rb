# frozen_string_literal: true

RSpec.describe Magick::TextureFill, '#dup' do
  def red_image
    Magick::Image.new(2, 2) { |options| options.background_color = 'red' }
  end

  it 'copies the texture' do
    fill = described_class.new(red_image)

    [fill.dup, fill.clone].each do |copy|
      image = Magick::Image.new(2, 2)
      copy.fill(image)
      expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
    end
  end

  it 'keeps its texture when the original is initialized again' do
    fill = described_class.new(red_image)
    copy = fill.dup

    fill.__send__(:initialize, Magick::Image.new(2, 2) { |options| options.background_color = 'blue' })

    image = Magick::Image.new(2, 2)
    copy.fill(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end

  it 'releases the texture it held when initialize_copy is called again' do
    texture = Magick::Image.new(1000, 1000)
    fill = described_class.new(texture)
    texture.destroy!
    GC.start
    baseline = Magick.resource_usage(:memory)

    fill.__send__(:initialize_copy, described_class.new(Magick::Image.new(1, 1)))

    expect(Magick.resource_usage(:memory)).to be < baseline
  end

  it 'raises RuntimeError when the original is not initialized' do
    fill = described_class.new(red_image)

    expect { described_class.allocate.dup }.to raise_error(RuntimeError, /has not been initialized/)
    expect { fill.__send__(:initialize_copy, described_class.allocate) }.to raise_error(RuntimeError, /has not been initialized/)

    image = Magick::Image.new(2, 2)
    fill.fill(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end

  it 'does nothing when initialize_copy is called with itself' do
    fill = described_class.new(red_image).freeze

    expect(fill.__send__(:initialize_copy, fill)).to be(fill)
  end

  it 'raises TypeError when initialize_copy is called with a fill of another class' do
    subclass = Class.new(described_class)

    expect { subclass.allocate.__send__(:initialize_copy, described_class.new(red_image)) }.to raise_error(TypeError)
  end

  it 'raises FrozenError when initialize_copy is called on a frozen fill' do
    fill = described_class.new(red_image).freeze

    expect { fill.__send__(:initialize_copy, described_class.new(Magick::Image.new(2, 2))) }.to raise_error(FrozenError)

    image = Magick::Image.new(2, 2)
    fill.fill(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end
end

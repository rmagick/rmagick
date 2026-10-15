# frozen_string_literal: true

RSpec.describe Magick::TextureFill, '#initialize' do
  it 'works' do
    granite = Magick::Image.read('granite:').first
    expect(described_class.new(granite)).to be_instance_of(described_class)
  end

  it 'accepts an ImageList argument' do
    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect(described_class.new(image_list)).to be_instance_of(described_class)
  end

  it 'raises an exception if an unexpected argument was given' do
    expect { described_class.new([1]) }.to raise_error(NoMethodError)
  end

  it 'releases the texture it held when initialize is called again' do
    texture = Magick::Image.new(1000, 1000)
    fill = described_class.new(texture)
    texture.destroy!
    GC.start
    baseline = Magick.resource_usage(:memory)

    fill.__send__(:initialize, Magick::Image.new(1, 1))

    expect(Magick.resource_usage(:memory)).to be < baseline
  end

  it 'raises FrozenError when initialize is called on a frozen fill' do
    red = Magick::Image.new(2, 2) { |options| options.background_color = 'red' }
    fill = described_class.new(red).freeze

    expect { fill.__send__(:initialize, Magick::Image.new(2, 2)) }.to raise_error(FrozenError)

    image = Magick::Image.new(2, 2)
    fill.fill(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end

  it 'raises FrozenError when the fill is frozen while the texture is converted' do
    red = Magick::Image.new(2, 2) { |options| options.background_color = 'red' }
    blue = Magick::Image.new(2, 2) { |options| options.background_color = 'blue' }
    fill = described_class.new(red)
    texture = Object.new
    texture.define_singleton_method(:cur_image) do
      fill.freeze
      blue
    end

    expect { fill.__send__(:initialize, texture) }.to raise_error(FrozenError)

    image = Magick::Image.new(2, 2)
    fill.fill(image)
    expect(image.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end
end

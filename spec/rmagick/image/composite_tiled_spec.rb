# frozen_string_literal: true

RSpec.describe Magick::Image, '#composite_tiled' do
  it 'works' do
    bg = described_class.new(200, 200)
    fg = described_class.new(50, 100) { |options| options.background_color = 'black' }

    result = bg.composite_tiled(fg)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(bg)
    expect(result).not_to be(fg)

    expect { bg.composite_tiled!(fg) }.not_to raise_error
    expect { bg.composite_tiled(fg, Magick::AtopCompositeOp) }.not_to raise_error
    expect { bg.composite_tiled(fg, Magick::OverCompositeOp) }.not_to raise_error
    expect { bg.composite_tiled(fg, Magick::RedChannel) }.not_to raise_error
    expect { bg.composite_tiled(fg, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error

    expect { bg.composite_tiled }.to raise_error(ArgumentError)
    expect { bg.composite_tiled(fg, 'x') }.to raise_error(TypeError)
    expect { bg.composite_tiled(fg, Magick::AtopCompositeOp, Magick::RedChannel, 'x') }.to raise_error(TypeError)

    fg.destroy!
    expect { bg.composite_tiled(fg) }.to raise_error(Magick::DestroyedImageError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.composite_tiled(image_list) }.not_to raise_error
    expect { image.composite_tiled(image_list, Magick::AtopCompositeOp) }.not_to raise_error
    expect { image.composite_tiled(image_list, Magick::RedChannel) }.not_to raise_error
    expect { image.composite_tiled(image_list, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error
  end

  it 'keeps the image that #cur_image returns alive while it tiles' do
    image = described_class.new(8, 4)
    overlay = described_class.new(4, 4) { |options| options.background_color = 'red' }
    source = Object.new
    source.define_singleton_method(:cur_image) { overlay.dup }

    result = with_gc_stress { image.composite_tiled(source) }
    with_gc_stress { image.composite_tiled!(source) }

    red = Magick::Pixel.from_color('red')
    expect(result.pixel_color(7, 3)).to eq(red)
    expect(image.pixel_color(7, 3)).to eq(red)
  end

  it 'frees the new image when the thread is interrupted' do
    cancelled = Class.new(StandardError)
    image = described_class.new(1000, 1000)
    overlay = described_class.new(20, 20)
    GC.start
    baseline = Magick.resource_usage(:memory)
    interrupt(cancelled, ready: -> { Magick.resource_usage(:memory) > baseline }) { image.composite_tiled(overlay) }
    3.times { GC.start }

    expect(Magick.resource_usage(:memory)).to be <= baseline
  end

  it 'restores the channel mask when the thread is interrupted' do
    cancelled = Class.new(StandardError)
    image = described_class.new(600, 600)
    overlay = described_class.new(20, 20)
    interrupt(cancelled) { image.composite_tiled!(overlay, Magick::OverCompositeOp, Magick::RedChannel) }

    expect(image.negate.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('black'))
  end

  it 'does not change a frozen overlay' do
    image = described_class.new(20, 20)
    overlay = described_class.new(5, 5).freeze

    image.composite_tiled(overlay)

    expect(overlay.artifact('modify-outside-overlay')).to be(nil)
  end
end

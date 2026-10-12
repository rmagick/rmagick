# frozen_string_literal: true

RSpec.describe Magick::Image, '#composite_mathematics' do
  it 'works' do
    bg = described_class.new(50, 50)
    fg = described_class.new(50, 50) { |options| options.background_color = 'black' }

    result = bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(bg)
    expect(result).not_to be(fg)

    expect { bg.composite_mathematics(fg, 1, 0, 0, 0, 0.0, 0.0) }.not_to raise_error
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity, 0.0, 0.0) }.not_to raise_error

    # too few arguments
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0) }.to raise_error(ArgumentError)
    # too many arguments
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity, 0.0, 0.0, 'x') }.to raise_error(ArgumentError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.composite_mathematics(image_list, 1, 0, 0, 0, Magick::CenterGravity) }.not_to raise_error
    expect { image.composite_mathematics(image_list, 1, 0, 0, 0, 0.0, 0.0) }.not_to raise_error
  end

  it 'does not change a frozen overlay' do
    image = described_class.new(20, 20)
    overlay = described_class.new(5, 5).freeze

    image.composite_mathematics(overlay, 1, 0, 0, 0, Magick::CenterGravity)

    expect(overlay.artifact('compose:args')).to be(nil)
  end

  it 'uses the coefficients' do
    image = described_class.new(4, 4) { |options| options.background_color = 'gray50' }
    overlay = described_class.new(4, 4) { |options| options.background_color = 'gray25' }

    source = image.composite_mathematics(overlay, 0, 1, 0, 0, Magick::NorthWestGravity)
    destination = image.composite_mathematics(overlay, 0, 0, 1, 0, Magick::NorthWestGravity)

    expect(source.pixel_color(0, 0)).to eq(overlay.pixel_color(0, 0))
    expect(destination.pixel_color(0, 0)).to eq(image.pixel_color(0, 0))
  end

  it 'does not keep the coefficients on the result' do
    image = described_class.new(4, 4)
    overlay = described_class.new(4, 4)

    result = image.composite_mathematics(overlay, 0, 1, 0, 0, Magick::NorthWestGravity)

    expect(result.artifact('compose:args')).to be(nil)
  end
end

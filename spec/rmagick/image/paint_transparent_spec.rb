# frozen_string_literal: true

RSpec.describe Magick::Image, '#paint_transparent' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.paint_transparent('red')
    expect(result).not_to be(nil)
    expect(result).to be_instance_of(described_class)
    expect(image).not_to be(result)

    expect { image.paint_transparent('red', alpha: Object.new) }.to raise_error(TypeError)
    expect { image.paint_transparent('red', alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.paint_transparent('red', wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.paint_transparent('red', Magick::TransparentAlpha, true) }.to raise_error(TypeError)
    expect { image.paint_transparent('red', true, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.paint_transparent('red', true, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.paint_transparent('red', true, alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.paint_transparent('red', Magick::TransparentAlpha, true, 50) }.to raise_error(ArgumentError)
    expect { image.paint_transparent('red', true, 50, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.paint_transparent('red', true, 50, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)

    # Too many arguments
    expect { image.paint_transparent('red', true, 50, 50, 50) }.to raise_error(ArgumentError)
    # Not enough
    expect { image.paint_transparent }.to raise_error(ArgumentError)
    expect { image.paint_transparent('red', true, [], alpha: Magick::TransparentAlpha) }.to raise_error(TypeError)
    expect { image.paint_transparent(50) }.to raise_error(TypeError)
  end

  it 'uses the given fuzz even when the image fuzz is larger' do
    image = described_class.new(2, 1)
    image.pixel_color(0, 0, 'gray20')
    image.fuzz = '50%'

    result = image.paint_transparent('black', false, 0)
    expect(result.pixel_color(0, 0).alpha).to eq(Magick::QuantumRange)
    expect(result.fuzz).to eq(image.fuzz)
  end

  it 'uses the given fuzz with invert too' do
    image = described_class.new(2, 1)
    image.pixel_color(0, 0, 'gray20')
    image.fuzz = '50%'

    result = image.paint_transparent('black', true, 0)
    expect(result.pixel_color(0, 0).alpha).to eq(0)
  end

  it 'raises ArgumentError for a negative fuzz' do
    image = described_class.new(2, 1)

    expect { image.paint_transparent('black', false, -0.1) }
      .to raise_error(ArgumentError, 'fuzz must be >= 0.0 (-0.1 given)')
  end

  it 'uses the image fuzz when no fuzz is given' do
    image = described_class.new(2, 1)
    image.pixel_color(0, 0, 'gray20')
    image.fuzz = '50%'

    result = image.paint_transparent('black')
    expect(result.pixel_color(0, 0).alpha).to eq(0)
  end
end

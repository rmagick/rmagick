RSpec.describe Magick::Image, '#paint_transparent' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.paint_transparent('red')
    expect(result).not_to be(nil)
    expect(result).to be_instance_of(described_class)
    expect(image).not_to be(result)

    expect { image.paint_transparent('red', Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.paint_transparent('red', alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.paint_transparent('red', wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.paint_transparent('red', Magick::TransparentAlpha, true) }.to raise_error(ArgumentError)
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
end

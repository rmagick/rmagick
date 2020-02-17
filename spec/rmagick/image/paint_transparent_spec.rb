RSpec.describe Magick::Image, '#paint_transparent' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.paint_transparent('red')
    expect(res).not_to be(nil)
    expect(res).to be_instance_of(described_class)
    expect(img).not_to be(res)

    expect { img.paint_transparent('red', Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { img.paint_transparent('red', alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { img.paint_transparent('red', wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { img.paint_transparent('red', Magick::TransparentAlpha, true) }.to raise_error(ArgumentError)
    expect { img.paint_transparent('red', true, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { img.paint_transparent('red', true, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { img.paint_transparent('red', true, alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { img.paint_transparent('red', Magick::TransparentAlpha, true, 50) }.to raise_error(ArgumentError)
    expect { img.paint_transparent('red', true, 50, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { img.paint_transparent('red', true, 50, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)

    # Too many arguments
    expect { img.paint_transparent('red', true, 50, 50, 50) }.to raise_error(ArgumentError)
    # Not enough
    expect { img.paint_transparent }.to raise_error(ArgumentError)
    expect { img.paint_transparent('red', true, [], alpha: Magick::TransparentAlpha) }.to raise_error(TypeError)
    expect { img.paint_transparent(50) }.to raise_error(TypeError)
  end
end

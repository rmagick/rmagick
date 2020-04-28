RSpec.describe Magick::Image, '#composite_tiled' do
  it 'works' do
    bg = described_class.new(200, 200)
    fg = described_class.new(50, 100) { self.background_color = 'black' }

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
end

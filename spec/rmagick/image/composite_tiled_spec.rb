RSpec.describe Magick::Image, '#composite_tiled' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    bg = described_class.new(200, 200)
    fg = described_class.new(50, 100) { self.background_color = 'black' }
    res = nil
    expect do
      res = bg.composite_tiled(fg)
    end.not_to raise_error
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(bg)
    expect(res).not_to be(fg)
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
end

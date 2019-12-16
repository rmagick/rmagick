RSpec.describe Magick::Image, '#composite_mathematics' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    bg = Magick::Image.new(50, 50)
    fg = Magick::Image.new(50, 50) { self.background_color = 'black' }
    res = nil
    expect { res = bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity) }.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(bg)
    expect(res).not_to be(fg)
    expect { res = bg.composite_mathematics(fg, 1, 0, 0, 0, 0.0, 0.0) }.not_to raise_error
    expect { res = bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity, 0.0, 0.0) }.not_to raise_error

    # too few arguments
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0) }.to raise_error(ArgumentError)
    # too many arguments
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity, 0.0, 0.0, 'x') }.to raise_error(ArgumentError)
  end
end

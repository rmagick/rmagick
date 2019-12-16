RSpec.describe Magick::Image, '#ordered_dither' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.ordered_dither
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.ordered_dither('3x3') }.not_to raise_error
    expect { @img.ordered_dither(2) }.not_to raise_error
    expect { @img.ordered_dither(3) }.not_to raise_error
    expect { @img.ordered_dither(4) }.not_to raise_error
    expect { @img.ordered_dither(5) }.to raise_error(ArgumentError)
    expect { @img.ordered_dither(2, 1) }.to raise_error(ArgumentError)
  end
end

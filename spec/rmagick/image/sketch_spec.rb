RSpec.describe Magick::Image, '#sketch' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect { @img.sketch }.not_to raise_error
    expect { @img.sketch(0) }.not_to raise_error
    expect { @img.sketch(0, 1) }.not_to raise_error
    expect { @img.sketch(0, 1, 0) }.not_to raise_error
    expect { @img.sketch(0, 1, 0, 1) }.to raise_error(ArgumentError)
    expect { @img.sketch('x') }.to raise_error(TypeError)
    expect { @img.sketch(0, 'x') }.to raise_error(TypeError)
    expect { @img.sketch(0, 1, 'x') }.to raise_error(TypeError)
  end
end

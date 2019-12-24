RSpec.describe Magick::Image, '#recolor' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect { @img.recolor([1, 1, 2, 1]) }.not_to raise_error
    expect { @img.recolor('x') }.to raise_error(TypeError)
    expect { @img.recolor([1, 1, 'x', 1]) }.to raise_error(TypeError)
  end
end

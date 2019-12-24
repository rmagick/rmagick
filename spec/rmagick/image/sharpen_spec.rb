RSpec.describe Magick::Image, '#sharpen' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.sharpen
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.sharpen(2.0) }.not_to raise_error
    expect { @img.sharpen(2.0, 1.0) }.not_to raise_error
    expect { @img.sharpen(2.0, 1.0, 2) }.to raise_error(ArgumentError)
    expect { @img.sharpen('x') }.to raise_error(TypeError)
    expect { @img.sharpen(2.0, 'x') }.to raise_error(TypeError)
  end
end

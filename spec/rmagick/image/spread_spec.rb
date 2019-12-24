RSpec.describe Magick::Image, '#spread' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.spread
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.spread(3.0) }.not_to raise_error
    expect { @img.spread(3.0, 2) }.to raise_error(ArgumentError)
    expect { @img.spread('x') }.to raise_error(TypeError)
  end
end

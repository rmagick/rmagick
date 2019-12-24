RSpec.describe Magick::Image, '#scale' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.scale(10, 10)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.scale(2) }.not_to raise_error
    expect { @img.scale }.to raise_error(ArgumentError)
    expect { @img.scale(25, 25, 25) }.to raise_error(ArgumentError)
    expect { @img.scale('x') }.to raise_error(TypeError)
    expect { @img.scale(10, 'x') }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#emboss' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.emboss
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.emboss(1.0) }.not_to raise_error
    expect { @img.emboss(1.0, 0.5) }.not_to raise_error
    expect { @img.emboss(1.0, 0.5, 2) }.to raise_error(ArgumentError)
    expect { @img.emboss(1.0, 'x') }.to raise_error(TypeError)
    expect { @img.emboss('x', 1.0) }.to raise_error(TypeError)
  end
end

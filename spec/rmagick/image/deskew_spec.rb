RSpec.describe Magick::Image, '#deskew' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.deskew
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    expect { @img.deskew(0.10) }.not_to raise_error
    expect { @img.deskew('95%') }.not_to raise_error
    expect { @img.deskew('x') }.to raise_error(ArgumentError)
    expect { @img.deskew(0.40, 'x') }.to raise_error(TypeError)
    expect { @img.deskew(0.40, 20, [1]) }.to raise_error(ArgumentError)
  end
end

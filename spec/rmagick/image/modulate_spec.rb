RSpec.describe Magick::Image, '#modulate' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.modulate
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.modulate(0.5) }.not_to raise_error
    expect { @img.modulate(0.5, 0.5) }.not_to raise_error
    expect { @img.modulate(0.5, 0.5, 0.5) }.not_to raise_error
    expect { @img.modulate(0.0, 0.5, 0.5) }.to raise_error(ArgumentError)
    expect { @img.modulate(0.5, 0.5, 0.5, 0.5) }.to raise_error(ArgumentError)
    expect { @img.modulate('x', 0.5, 0.5) }.to raise_error(TypeError)
    expect { @img.modulate(0.5, 'x', 0.5) }.to raise_error(TypeError)
    expect { @img.modulate(0.5, 0.5, 'x') }.to raise_error(TypeError)
  end
end

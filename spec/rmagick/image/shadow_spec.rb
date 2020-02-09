RSpec.describe Magick::Image, '#shadow' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.shadow
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { @img.shadow(5) }.not_to raise_error
    expect { @img.shadow(5, 5) }.not_to raise_error
    expect { @img.shadow(5, 5, 3.0) }.not_to raise_error
    expect { @img.shadow(5, 5, 3.0, 0.50) }.not_to raise_error
    expect { @img.shadow(5, 5, 3.0, '50%') }.not_to raise_error
    expect { @img.shadow(5, 5, 3.0, 0.50, 2) }.to raise_error(ArgumentError)
    expect { @img.shadow('x') }.to raise_error(TypeError)
    expect { @img.shadow(5, 'x') }.to raise_error(TypeError)
    expect { @img.shadow(5, 5, 'x') }.to raise_error(TypeError)
    expect { @img.shadow(5, 5, 3.0, 'x') }.to raise_error(ArgumentError)
  end
end

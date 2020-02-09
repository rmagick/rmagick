RSpec.describe Magick::Image, '#displace' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    @img2 = described_class.new(20, 20) { self.background_color = 'black' }
    expect { @img.displace(@img2, 25) }.not_to raise_error
    res = @img.displace(@img2, 25)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(@img)
    expect { @img.displace(@img2, 25, 25) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, 10) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, 10, 10) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity, 10) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity, 10, 10) }.not_to raise_error
    expect { @img.displace }.to raise_error(ArgumentError)
    expect { @img.displace(@img2, 'x') }.to raise_error(TypeError)
    expect { @img.displace(@img2, 25, []) }.to raise_error(TypeError)
    expect { @img.displace(@img2, 25, 25, 'x') }.to raise_error(TypeError)
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity, 'x') }.to raise_error(TypeError)
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity, 10, []) }.to raise_error(TypeError)

    @img2.destroy!
    expect { @img.displace(@img2, 25, 25) }.to raise_error(Magick::DestroyedImageError)
  end
end

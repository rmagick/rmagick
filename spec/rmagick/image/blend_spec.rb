RSpec.describe Magick::Image, "#blend" do
  it "works" do
    img = described_class.new(20, 20)
    img2 = described_class.new(20, 20) { self.background_color = 'black' }

    expect { img.blend(img2, 0.25) }.not_to raise_error
    res = img.blend(img2, 0.25)

    Magick::GravityType.values do |gravity|
      expect { img.blend(img2, 0.25, 0.75, gravity) }.not_to raise_error
      expect { img.blend(img2, 0.25, 0.75, gravity, 10) }.not_to raise_error
      expect { img.blend(img2, 0.25, 0.75, gravity, 10, 10) }.not_to raise_error
    end

    expect(res).to be_instance_of(described_class)
    expect { img.blend(img2, '25%') }.not_to raise_error
    expect { img.blend(img2, 0.25, 0.75) }.not_to raise_error
    expect { img.blend(img2, '25%', '75%') }.not_to raise_error
    expect { img.blend }.to raise_error(ArgumentError)
    expect { img.blend(img2, 'x') }.to raise_error(ArgumentError)
    expect { img.blend(img2, 0.25, []) }.to raise_error(TypeError)
    expect { img.blend(img2, 0.25, 0.75, 'x') }.to raise_error(TypeError)
    expect { img.blend(img2, 0.25, 0.75, Magick::CenterGravity, 'x') }.to raise_error(TypeError)
    expect { img.blend(img2, 0.25, 0.75, Magick::CenterGravity, 10, []) }.to raise_error(TypeError)

    img2.destroy!
    expect { img.blend(img2, '25%') }.to raise_error(Magick::DestroyedImageError)
  end
end

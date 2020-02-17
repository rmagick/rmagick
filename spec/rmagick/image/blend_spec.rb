RSpec.describe Magick::Image, "#blend" do
  it "works" do
    image = described_class.new(20, 20)
    image2 = described_class.new(20, 20) { self.background_color = 'black' }

    expect { image.blend(image2, 0.25) }.not_to raise_error
    res = image.blend(image2, 0.25)

    Magick::GravityType.values do |gravity|
      expect { image.blend(image2, 0.25, 0.75, gravity) }.not_to raise_error
      expect { image.blend(image2, 0.25, 0.75, gravity, 10) }.not_to raise_error
      expect { image.blend(image2, 0.25, 0.75, gravity, 10, 10) }.not_to raise_error
    end

    expect(res).to be_instance_of(described_class)
    expect { image.blend(image2, '25%') }.not_to raise_error
    expect { image.blend(image2, 0.25, 0.75) }.not_to raise_error
    expect { image.blend(image2, '25%', '75%') }.not_to raise_error
    expect { image.blend }.to raise_error(ArgumentError)
    expect { image.blend(image2, 'x') }.to raise_error(ArgumentError)
    expect { image.blend(image2, 0.25, []) }.to raise_error(TypeError)
    expect { image.blend(image2, 0.25, 0.75, 'x') }.to raise_error(TypeError)
    expect { image.blend(image2, 0.25, 0.75, Magick::CenterGravity, 'x') }.to raise_error(TypeError)
    expect { image.blend(image2, 0.25, 0.75, Magick::CenterGravity, 10, []) }.to raise_error(TypeError)

    image2.destroy!
    expect { image.blend(image2, '25%') }.to raise_error(Magick::DestroyedImageError)
  end
end

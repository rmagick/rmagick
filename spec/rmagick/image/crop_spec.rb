RSpec.describe Magick::Image, '#crop' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.crop }.to raise_error(ArgumentError)
    expect { image.crop(0, 0) }.to raise_error(ArgumentError)

    result = image.crop(0, 0, image.columns / 2, image.rows / 2)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    # 3-argument form
    Magick::GravityType.values do |grav|
      expect { image.crop(grav, image.columns / 2, image.rows / 2) }.not_to raise_error
    end
    expect { image.crop(2, image.columns / 2, image.rows / 2) }.to raise_error(TypeError)
    expect { image.crop(Magick::NorthWestGravity, image.columns / 2, image.rows / 2, 2) }.to raise_error(TypeError)

    # 4-argument form
    expect { image.crop(0, 0, image.columns / 2, 'x') }.to raise_error(TypeError)
    expect { image.crop(0, 0, 'x', image.rows / 2) }.to raise_error(TypeError)
    expect { image.crop(0, 'x', image.columns / 2, image.rows / 2) }.to raise_error(TypeError)
    expect { image.crop('x', 0, image.columns / 2, image.rows / 2) }.to raise_error(TypeError)
    expect { image.crop(0, 0, image.columns / 2, image.rows / 2, 2) }.to raise_error(TypeError)

    # 5-argument form
    Magick::GravityType.values do |grav|
      expect { image.crop(grav, 0, 0, image.columns / 2, image.rows / 2) }.not_to raise_error
    end

    expect { image.crop(Magick::NorthWestGravity, 0, 0, image.columns / 2, image.rows / 2, 2) }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Image, '#crop' do
  it 'works' do
    img = described_class.new(20, 20)

    expect { img.crop }.to raise_error(ArgumentError)
    expect { img.crop(0, 0) }.to raise_error(ArgumentError)
    expect do
      res = img.crop(0, 0, img.columns / 2, img.rows / 2)
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end.not_to raise_error

    # 3-argument form
    Magick::GravityType.values do |grav|
      expect { img.crop(grav, img.columns / 2, img.rows / 2) }.not_to raise_error
    end
    expect { img.crop(2, img.columns / 2, img.rows / 2) }.to raise_error(TypeError)
    expect { img.crop(Magick::NorthWestGravity, img.columns / 2, img.rows / 2, 2) }.to raise_error(TypeError)

    # 4-argument form
    expect { img.crop(0, 0, img.columns / 2, 'x') }.to raise_error(TypeError)
    expect { img.crop(0, 0, 'x', img.rows / 2) }.to raise_error(TypeError)
    expect { img.crop(0, 'x', img.columns / 2, img.rows / 2) }.to raise_error(TypeError)
    expect { img.crop('x', 0, img.columns / 2, img.rows / 2) }.to raise_error(TypeError)
    expect { img.crop(0, 0, img.columns / 2, img.rows / 2, 2) }.to raise_error(TypeError)

    # 5-argument form
    Magick::GravityType.values do |grav|
      expect { img.crop(grav, 0, 0, img.columns / 2, img.rows / 2) }.not_to raise_error
    end

    expect { img.crop(Magick::NorthWestGravity, 0, 0, img.columns / 2, img.rows / 2, 2) }.to raise_error(ArgumentError)
  end
end

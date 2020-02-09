RSpec.describe Magick::Image, '#resample' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    @img.x_resolution = 72
    @img.y_resolution = 72
    expect { @img.resample }.not_to raise_error
    expect { @img.resample(100) }.not_to raise_error
    expect { @img.resample(100, 100) }.not_to raise_error

    @img.x_resolution = 0
    @img.y_resolution = 0
    expect { @img.resample }.not_to raise_error
    expect { @img.resample(100) }.not_to raise_error
    expect { @img.resample(100, 100) }.not_to raise_error

    girl = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    expect(girl.x_resolution).to eq(240.0)
    expect(girl.y_resolution).to eq(240.0)
    res = girl.resample(120, 120)
    expect(res.columns).to eq(100)
    expect(res.rows).to eq(125)
    expect(res.x_resolution).to eq(120.0)
    expect(res.y_resolution).to eq(120.0)
    expect(girl.columns).to eq(200)
    expect(girl.rows).to eq(250)
    expect(girl.x_resolution).to eq(240.0)
    expect(girl.y_resolution).to eq(240.0)

    Magick::FilterType.values do |filter|
      expect { @img.resample(50, 50, filter) }.not_to raise_error
    end
    expect { @img.resample(50, 50, Magick::PointFilter, 2.0) }.not_to raise_error

    expect { @img.resample('x') }.to raise_error(TypeError)
    expect { @img.resample(100, 'x') }.to raise_error(TypeError)
    expect { @img.resample(50, 50, 2) }.to raise_error(TypeError)
    expect { @img.resample(50, 50, Magick::CubicFilter, 'x') }.to raise_error(TypeError)
    expect { @img.resample(50, 50, Magick::SincFilter, 2.0, 'x') }.to raise_error(ArgumentError)
    expect { @img.resample(-100) }.to raise_error(ArgumentError)
    expect { @img.resample(100, -100) }.to raise_error(ArgumentError)
  end
end

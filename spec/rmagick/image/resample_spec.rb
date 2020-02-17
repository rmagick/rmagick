RSpec.describe Magick::Image, '#resample' do
  it 'works' do
    image = described_class.new(20, 20)
    image.x_resolution = 72
    image.y_resolution = 72

    expect { image.resample }.not_to raise_error
    expect { image.resample(100) }.not_to raise_error
    expect { image.resample(100, 100) }.not_to raise_error

    image.x_resolution = 0
    image.y_resolution = 0
    expect { image.resample }.not_to raise_error
    expect { image.resample(100) }.not_to raise_error
    expect { image.resample(100, 100) }.not_to raise_error

    girl = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    expect(girl.x_resolution).to eq(240.0)
    expect(girl.y_resolution).to eq(240.0)
    result = girl.resample(120, 120)
    expect(result.columns).to eq(100)
    expect(result.rows).to eq(125)
    expect(result.x_resolution).to eq(120.0)
    expect(result.y_resolution).to eq(120.0)
    expect(girl.columns).to eq(200)
    expect(girl.rows).to eq(250)
    expect(girl.x_resolution).to eq(240.0)
    expect(girl.y_resolution).to eq(240.0)

    Magick::FilterType.values do |filter|
      expect { image.resample(50, 50, filter) }.not_to raise_error
    end
    expect { image.resample(50, 50, Magick::PointFilter, 2.0) }.not_to raise_error

    expect { image.resample('x') }.to raise_error(TypeError)
    expect { image.resample(100, 'x') }.to raise_error(TypeError)
    expect { image.resample(50, 50, 2) }.to raise_error(TypeError)
    expect { image.resample(50, 50, Magick::CubicFilter, 'x') }.to raise_error(TypeError)
    expect { image.resample(50, 50, Magick::SincFilter, 2.0, 'x') }.to raise_error(ArgumentError)
    expect { image.resample(-100) }.to raise_error(ArgumentError)
    expect { image.resample(100, -100) }.to raise_error(ArgumentError)
  end
end

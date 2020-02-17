RSpec.describe Magick::Image, '#resize' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.resize(2)
    expect(res).to be_instance_of(described_class)

    expect { image.resize(50, 50) }.not_to raise_error

    Magick::FilterType.values do |filter|
      expect { image.resize(50, 50, filter) }.not_to raise_error
    end
    expect { image.resize(50, 50, Magick::PointFilter, 2.0) }.not_to raise_error
    expect { image.resize('x') }.to raise_error(TypeError)
    expect { image.resize(50, 'x') }.to raise_error(TypeError)
    expect { image.resize(50, 50, 2) }.to raise_error(TypeError)
    expect { image.resize(50, 50, Magick::CubicFilter, 'x') }.to raise_error(TypeError)
    expect { image.resize(-1.0) }.to raise_error(ArgumentError)
    expect { image.resize(0, 50) }.to raise_error(ArgumentError)
    expect { image.resize(50, 0) }.to raise_error(ArgumentError)
    expect { image.resize(50, 50, Magick::SincFilter, 2.0, 'x') }.to raise_error(ArgumentError)
    expect { image.resize }.to raise_error(ArgumentError)
  end
end

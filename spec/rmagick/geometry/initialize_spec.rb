RSpec.describe Magick::Geometry, '#initialize' do
  it 'works' do
    expect { described_class.new(Magick::PercentGeometry) }.to raise_error(ArgumentError)
    expect { described_class.new(0, Magick::PercentGeometry) }.to raise_error(ArgumentError)
    expect { described_class.new(0, 0, Magick::PercentGeometry) }.to raise_error(ArgumentError)
    expect { described_class.new(0, 0, 0, Magick::PercentGeometry) }.to raise_error(ArgumentError)

    expect { described_class.new(-1) }.to raise_error(ArgumentError)
    expect { described_class.new(0, -1) }.to raise_error(ArgumentError)

    geometry = described_class.new
    expect(geometry.width).to eq(0)
    expect(geometry.height).to eq(0)
    expect(geometry.x).to eq(0)
    expect(geometry.y).to eq(0)
    expect(geometry.flag).to be(nil)

    geometry = described_class.new(10, 20, 30, 40)
    expect(geometry.width).to eq(10)
    expect(geometry.height).to eq(20)
    expect(geometry.x).to eq(30)
    expect(geometry.y).to eq(40)
  end
end

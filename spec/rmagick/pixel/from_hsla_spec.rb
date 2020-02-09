RSpec.describe Magick::Pixel, '#from_hsla' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    expect { described_class.from_hsla(127, 50, 50) }.not_to raise_error
    expect { described_class.from_hsla(127, 50, 50, 0) }.not_to raise_error
    expect { described_class.from_hsla('99%', '100%', '100%', '100%') }.not_to raise_error
    expect { described_class.from_hsla(0, 0, 0, 0) }.not_to raise_error
    expect { described_class.from_hsla(359, 255, 255, 1.0) }.not_to raise_error
    expect { described_class.from_hsla([], 50, 50, 0) }.to raise_error(TypeError)
    expect { described_class.from_hsla(127, [], 50, 0) }.to raise_error(TypeError)
    expect { described_class.from_hsla(127, 50, [], 0) }.to raise_error(TypeError)
    expect { described_class.from_hsla }.to raise_error(ArgumentError)
    expect { described_class.from_hsla(127, 50, 50, 50, 50) }.to raise_error(ArgumentError)
    expect { described_class.from_hsla(-0.01, 0, 0) }.to raise_error(ArgumentError)
    expect { described_class.from_hsla(0, -0.01, 0) }.to raise_error(ArgumentError)
    expect { described_class.from_hsla(0, 0, -0.01) }.to raise_error(ArgumentError)
    expect { described_class.from_hsla(0, 0, 0, -0.01) }.to raise_error(ArgumentError)
    expect { described_class.from_hsla(0, 0, 0, 1.01) }.to raise_error(RangeError)
    expect { described_class.from_hsla(360, 0, 0) }.to raise_error(RangeError)
    expect { described_class.from_hsla(0, 256, 0) }.to raise_error(RangeError)
    expect { described_class.from_hsla(0, 0, 256) }.to raise_error(RangeError)
    expect { @pixel.to_hsla }.not_to raise_error

    args = [200, 125.125, 250.5, 0.6]
    px = described_class.from_hsla(*args)
    hsla = px.to_hsla
    expect(hsla[0]).to be_within(0.25).of(args[0])
    expect(hsla[1]).to be_within(0.25).of(args[1])
    expect(hsla[2]).to be_within(0.25).of(args[2])
    expect(hsla[3]).to be_within(0.005).of(args[3])

    # test percentages
    args = ['20%', '20%', '20%', '20%']
    args2 = [360.0 / 5, 255.0 / 5, 255.0 / 5, 1.0 / 5]
    px = described_class.from_hsla(*args)
    hsla = px.to_hsla
    px2 = described_class.from_hsla(*args2)
    hsla2 = px2.to_hsla

    expect(hsla2[0]).to be_within(0.25).of(hsla[0])
    expect(hsla2[1]).to be_within(0.25).of(hsla[1])
    expect(hsla2[2]).to be_within(0.25).of(hsla[2])
    expect(hsla2[3]).to be_within(0.005).of(hsla[3])
  end
end

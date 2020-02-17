RSpec.describe Magick::Image, '#ordered_dither' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.ordered_dither
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.ordered_dither('3x3') }.not_to raise_error
    expect { image.ordered_dither(2) }.not_to raise_error
    expect { image.ordered_dither(3) }.not_to raise_error
    expect { image.ordered_dither(4) }.not_to raise_error
    expect { image.ordered_dither(5) }.to raise_error(ArgumentError)
    expect { image.ordered_dither(2, 1) }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Image, '#sharpen' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.sharpen
    expect(res).to be_instance_of(described_class)

    expect { img.sharpen(2.0) }.not_to raise_error
    expect { img.sharpen(2.0, 1.0) }.not_to raise_error
    expect { img.sharpen(2.0, 1.0, 2) }.to raise_error(ArgumentError)
    expect { img.sharpen('x') }.to raise_error(TypeError)
    expect { img.sharpen(2.0, 'x') }.to raise_error(TypeError)
  end
end

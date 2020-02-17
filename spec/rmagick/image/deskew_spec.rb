RSpec.describe Magick::Image, '#deskew' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.deskew
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.deskew(0.10) }.not_to raise_error
    expect { image.deskew('95%') }.not_to raise_error
    expect { image.deskew('x') }.to raise_error(ArgumentError)
    expect { image.deskew(0.40, 'x') }.to raise_error(TypeError)
    expect { image.deskew(0.40, 20, [1]) }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Image, '#deskew' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.deskew
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)

    expect { img.deskew(0.10) }.not_to raise_error
    expect { img.deskew('95%') }.not_to raise_error
    expect { img.deskew('x') }.to raise_error(ArgumentError)
    expect { img.deskew(0.40, 'x') }.to raise_error(TypeError)
    expect { img.deskew(0.40, 20, [1]) }.to raise_error(ArgumentError)
  end
end

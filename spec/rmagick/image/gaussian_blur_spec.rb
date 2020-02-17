RSpec.describe Magick::Image, '#gaussian_blur' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.gaussian_blur
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.gaussian_blur(0.0) }.not_to raise_error
    expect { image.gaussian_blur(0.0, 3.0) }.not_to raise_error
    # sigma must be != 0.0
    expect { image.gaussian_blur(1.0, 0.0) }.to raise_error(ArgumentError)
    expect { image.gaussian_blur(1.0, 3.0, 2) }.to raise_error(ArgumentError)
  end
end

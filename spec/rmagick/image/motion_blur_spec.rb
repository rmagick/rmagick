RSpec.describe Magick::Image, '#motion_blur' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.motion_blur(1.0, 7.0, 180)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.motion_blur(1.0, 0.0, 180) }.to raise_error(ArgumentError)
    expect { image.motion_blur(1.0, -1.0, 180) }.not_to raise_error
  end
end

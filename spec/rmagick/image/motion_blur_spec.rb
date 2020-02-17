RSpec.describe Magick::Image, '#motion_blur' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.motion_blur(1.0, 7.0, 180)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.motion_blur(1.0, 0.0, 180) }.to raise_error(ArgumentError)
    expect { image.motion_blur(1.0, -1.0, 180) }.not_to raise_error
  end
end

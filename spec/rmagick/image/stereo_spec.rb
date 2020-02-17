RSpec.describe Magick::Image, '#stereo' do
  it 'works' do
    image1 = described_class.new(20, 20)

    result = image1.stereo(image1)
    expect(result).to be_instance_of(described_class)

    image2 = described_class.new(20, 20)
    image2.destroy!
    expect { image1.stereo(image2) }.to raise_error(Magick::DestroyedImageError)
  end
end

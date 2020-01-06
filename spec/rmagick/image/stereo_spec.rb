RSpec.describe Magick::Image, '#stereo' do
  it 'works' do
    img1 = described_class.new(20, 20)

    expect do
      res = img1.stereo(img1)
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error

    img2 = described_class.new(20, 20)
    img2.destroy!
    expect { img1.stereo(img2) }.to raise_error(Magick::DestroyedImageError)
  end
end

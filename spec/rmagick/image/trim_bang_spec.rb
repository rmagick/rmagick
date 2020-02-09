RSpec.describe Magick::Image, '#trim!' do
  it 'works' do
    hat = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    expect do
      res = hat.trim!
      expect(res).to be(hat)

      res = hat.trim!(10)
      expect(res).to be(hat)
    end.not_to raise_error
    expect { hat.trim!(10, 10) }.to raise_error(ArgumentError)
  end
end

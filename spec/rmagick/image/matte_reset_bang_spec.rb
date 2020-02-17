RSpec.describe Magick::Image, '#matte_reset!' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.matte_reset!
    expect(res).to be(image)
  end
end

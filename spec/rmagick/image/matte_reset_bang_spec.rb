RSpec.describe Magick::Image, '#matte_reset!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.matte_reset!
    expect(result).to be(image)
  end
end

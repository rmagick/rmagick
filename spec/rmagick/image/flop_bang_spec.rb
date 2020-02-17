RSpec.describe Magick::Image, '#flop!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.flop!
    expect(result).to be(image)
  end
end

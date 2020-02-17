RSpec.describe Magick::Image, '#flop!' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.flop!
    expect(res).to be(image)
  end
end

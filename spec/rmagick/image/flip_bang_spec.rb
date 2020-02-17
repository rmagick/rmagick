RSpec.describe Magick::Image, '#flip!' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.flip!
    expect(res).to be(image)
  end
end

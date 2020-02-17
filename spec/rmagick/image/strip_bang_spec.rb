RSpec.describe Magick::Image, '#strip!' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.strip!
    expect(res).to be(image)
  end
end

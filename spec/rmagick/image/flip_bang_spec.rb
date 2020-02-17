RSpec.describe Magick::Image, '#flip!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.flip!
    expect(result).to be(image)
  end
end

RSpec.describe Magick::Image, '#strip!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.strip!
    expect(result).to be(image)
  end
end

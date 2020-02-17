RSpec.describe Magick::Image, '#erase!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.erase!
    expect(result).to be(image)
  end
end

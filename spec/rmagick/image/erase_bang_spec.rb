RSpec.describe Magick::Image, '#erase!' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.erase!
    expect(res).to be(image)
  end
end

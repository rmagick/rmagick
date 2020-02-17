RSpec.describe Magick::Image, '#erase!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.erase!
    expect(res).to be(img)
  end
end

RSpec.describe Magick::Image, '#flip!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.flip!
    expect(res).to be(img)
  end
end

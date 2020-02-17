RSpec.describe Magick::Image, '#strip!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.strip!
    expect(res).to be(img)
  end
end

RSpec.describe Magick::Image, '#crop!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.crop!(0, 0, img.columns / 2, img.rows / 2)
    expect(res).to be(img)
  end
end

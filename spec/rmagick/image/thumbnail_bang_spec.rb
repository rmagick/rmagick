RSpec.describe Magick::Image, '#thumbnail!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.thumbnail!(2)
    expect(res).to be(img)

    img.freeze
    expect { img.thumbnail!(0.50) }.to raise_error(FreezeError)
  end
end

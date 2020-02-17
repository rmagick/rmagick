RSpec.describe Magick::Image, '#thumbnail!' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.thumbnail!(2)
    expect(res).to be(image)

    image.freeze
    expect { image.thumbnail!(0.50) }.to raise_error(FreezeError)
  end
end

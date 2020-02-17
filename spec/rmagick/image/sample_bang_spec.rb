RSpec.describe Magick::Image, '#sample!' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.sample!(2)
    expect(res).to be(image)

    image.freeze
    expect { image.sample!(0.50) }.to raise_error(FreezeError)
  end
end

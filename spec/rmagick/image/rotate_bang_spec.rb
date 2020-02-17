RSpec.describe Magick::Image, '#rotate!' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.rotate!(45)
    expect(res).to be(image)

    image.freeze
    expect { image.rotate!(45) }.to raise_error(FreezeError)
  end
end

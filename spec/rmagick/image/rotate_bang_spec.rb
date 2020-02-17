RSpec.describe Magick::Image, '#rotate!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.rotate!(45)
    expect(res).to be(img)

    img.freeze
    expect { img.rotate!(45) }.to raise_error(FreezeError)
  end
end

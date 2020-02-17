RSpec.describe Magick::Image, '#scale!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.scale!(2)
    expect(res).to be(img)

    img.freeze
    expect { img.scale!(0.50) }.to raise_error(FreezeError)
  end
end

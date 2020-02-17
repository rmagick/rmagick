RSpec.describe Magick::Image, '#sample!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.sample!(2)
    expect(res).to be(img)

    img.freeze
    expect { img.sample!(0.50) }.to raise_error(FreezeError)
  end
end

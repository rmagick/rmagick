RSpec.describe Magick::Image, '#resize!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.resize!(2)
    expect(res).to be(img)

    img.freeze
    expect { img.resize!(0.50) }.to raise_error(FreezeError)
  end
end

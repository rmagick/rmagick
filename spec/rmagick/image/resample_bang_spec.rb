RSpec.describe Magick::Image, '#resample!' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.resample!(50)
    expect(res).to be(img)

    img.freeze
    expect { img.resample!(50) }.to raise_error(FreezeError)
  end
end

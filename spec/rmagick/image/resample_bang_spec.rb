RSpec.describe Magick::Image, '#resample!' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.resample!(50)
    expect(res).to be(image)

    image.freeze
    expect { image.resample!(50) }.to raise_error(FreezeError)
  end
end

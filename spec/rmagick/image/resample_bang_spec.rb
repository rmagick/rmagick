RSpec.describe Magick::Image, '#resample!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.resample!(50)
    expect(result).to be(image)

    image.freeze
    expect { image.resample!(50) }.to raise_error(FreezeError)
  end
end

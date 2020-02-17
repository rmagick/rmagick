RSpec.describe Magick::Image, '#scale!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.scale!(2)
    expect(result).to be(image)

    image.freeze
    expect { image.scale!(0.50) }.to raise_error(FreezeError)
  end
end

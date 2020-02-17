RSpec.describe Magick::Image, '#resize!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.resize!(2)
    expect(result).to be(image)

    image.freeze
    expect { image.resize!(0.50) }.to raise_error(FreezeError)
  end
end

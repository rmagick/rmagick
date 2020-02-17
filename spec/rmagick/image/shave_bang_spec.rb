RSpec.describe Magick::Image, '#shave' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.shave!(5, 5)
    expect(result).to be(image)

    image.freeze
    expect { image.shave!(2, 2) }.to raise_error(FreezeError)
  end
end

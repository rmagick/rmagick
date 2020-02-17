RSpec.describe Magick::Image, '#crop!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.crop!(0, 0, image.columns / 2, image.rows / 2)
    expect(result).to be(image)
  end
end

RSpec.describe Magick::Image, '#matte_replace' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.matte_replace(image.columns / 2, image.rows / 2)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)
  end
end

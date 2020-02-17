RSpec.describe Magick::Image, '#matte_replace' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.matte_replace(image.columns / 2, image.rows / 2)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)
  end
end

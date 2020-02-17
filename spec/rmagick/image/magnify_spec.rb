RSpec.describe Magick::Image, '#magnify' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.magnify
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    result = image.magnify!
    expect(result).to be(image)
  end
end

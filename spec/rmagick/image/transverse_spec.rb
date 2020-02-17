RSpec.describe Magick::Image, '#transverse' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.transverse
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    result = image.transverse!
    expect(result).to be_instance_of(described_class)
    expect(result).to be(image)
  end
end

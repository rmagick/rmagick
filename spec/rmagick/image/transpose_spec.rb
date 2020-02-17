RSpec.describe Magick::Image, '#transpose' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.transpose
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    res = image.transpose!
    expect(res).to be_instance_of(described_class)
    expect(res).to be(image)
  end
end

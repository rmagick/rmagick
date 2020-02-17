RSpec.describe Magick::Image, '#transverse' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.transverse
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    res = image.transverse!
    expect(res).to be_instance_of(described_class)
    expect(res).to be(image)
  end
end

RSpec.describe Magick::Image, '#despeckle' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.despeckle
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)
  end
end
